# Money Locket - iOS Social Finance App

Money Locket bridges the visual sharing mechanics of the popular "Locket Widget" with an Income/Expense ledger system. It utilizes standard MVVM Architecture with SwiftUI, AVFoundation for custom shaped viewfinder overlays, and is ready for real-time cloud sync.

---

## 📂 Project Directory Structure

Your project is organized as follows:
```
MoneyLocket/
├── MoneyLocketApp.swift         # Root App Scene launcher
├── Models/                      # Decodable & Encodable structs
│   ├── User.swift               # Profile metadata
│   ├── Transaction.swift        # Ledger (Income/Expense/Social)
│   ├── Message.swift            # Chat messages
│   └── Friend.swift             # Social graph edges
├── Views/                       # SwiftUI View Layouts
│   ├── Navigation/
│   │   └── MainTabView.swift    # Sleek floating tab navigation
│   ├── Camera/
│   │   ├── CameraView.swift     # Custom view finder (Square vs Heart)
│   │   ├── CameraPreview.swift  # AVFoundation wrapper
│   │   ├── HeartShape.swift     # Vector math for Heart mask
│   │   └── CustomZoomSlider.swift # Drag-to-zoom vertical slider
│   ├── Finance/
│   │   ├── WalletDashboardView.swift # Aggregations & Doughnut Charts
│   │   └── TransactionInputModal.swift # Ledger inputs & VND formatter
│   ├── Chat/
│   │   ├── ChatListView.swift   # DM list with friend status
│   │   └── ChatDetailView.swift # Messaging chat room
│   └── Friends/
│       ├── FriendsListView.swift # Manage friends and requests
│       └── WidgetSettingsView.swift # iOS Widget screen layout preview
├── ViewModels/                  # State containers managing business logic
│   ├── CameraViewModel.swift
│   ├── WalletViewModel.swift
│   ├── ChatViewModel.swift
│   └── FriendsViewModel.swift
└── README.md                    # This developer reference
```

---

## 🗄️ Database Setup & Sync Strategies

Depending on whether you choose **Supabase (Relational SQL)** or **Firebase (Document-based NoSQL)**, here is the setup guide.

### Option A: Supabase (PostgreSQL) — *Recommended*
PostgreSQL allows direct calculation of balances and category breakdowns on the server via simple queries, keeping mobile client sync logic straightforward.

#### 1. Setup SQL Schema
Execute this script inside the Supabase SQL Editor:
```sql
-- Create Profile Table
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique not null,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- Create Friendships
create table public.friendships (
  id uuid default gen_random_uuid() primary key,
  requester_id uuid references public.profiles(id) on delete cascade not null,
  receiver_id uuid references public.profiles(id) on delete cascade not null,
  status text check (status in ('pending', 'accepted', 'blocked')) not null default 'pending',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(requester_id, receiver_id)
);

alter table public.friendships enable row level security;

-- Create Transactions & Locket Posts
create table public.transactions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  photo_url text,
  amount numeric(15, 2) default 0.00,
  type text check (type in ('income', 'expense', 'social_only')) not null,
  category text check (category in ('Dining', 'Shopping', 'Transport', 'Friends', 'Others')) not null,
  notes text,
  latitude double precision,
  longitude double precision,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.transactions enable row level security;

-- Create Messages Table
create table public.messages (
  id uuid default gen_random_uuid() primary key,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  receiver_id uuid references public.profiles(id) on delete cascade not null,
  text_content text,
  photo_url text,
  transaction_id uuid references public.transactions(id) on delete set null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.messages enable row level security;
```

#### 2. Row Level Security (RLS) Policy Example
To prevent users from viewing private transactions of others while allowing friends to view social-only locket photos:
```sql
-- Allow users to read their own transactions
create policy "Allow users to manage own transactions" 
on public.transactions for all 
using (auth.uid() = user_id);

-- Allow users to view social locket photos of their accepted friends
create policy "Allow friends to view social locket photos" 
on public.transactions for select
using (
  type = 'social_only' AND
  user_id in (
    select requester_id from public.friendships where receiver_id = auth.uid() and status = 'accepted'
    union
    select receiver_id from public.friendships where requester_id = auth.uid() and status = 'accepted'
  )
);
```

#### 3. Supabase Client Integration (Swift)
Add the dependency `supabase-swift` to your Swift Package Manager.
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://your-project.supabase.co")!,
    supabaseKey: "your-anon-key"
)

// Fetching transactions with photo thumbnails
func fetchTransactions() async throws -> [Transaction] {
    let response: [Transaction] = try await supabase.database
        .from("transactions")
        .select()
        .order("created_at", ascending: false)
        .execute()
        .value
    return response
}
```

---

### Option B: Firebase Firestore (NoSQL)
Firestore simplifies real-time document listener bindings on iOS.

#### 1. Security Rules configuration
Place these inside the Firebase Console rules page:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User Profiles
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Transactions
    match /transactions/{transactionId} {
      allow write: if request.auth != null && request.auth.uid == request.resource.data.userId;
      
      // Read rule: Owner can read everything, friends can only read social posts
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid || 
        resource.data.type == 'social_only'
      );
    }
    
    // Messages
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📲 WidgetKit Integration Tips (Home Screen Widget)

To push the latest locket photos straight to the User's Home Screen Widget:

1. **Enable App Groups**:
   Add the `App Groups` capability to both your Main App target and Widget target in Xcode. Use a shared container like `group.com.yourname.money-locket`.
2. **Writing Data to Shared UserDefaults**:
   In `FriendsViewModel.swift` / `CameraViewModel.swift`, save the latest locket image URL or data to the shared container:
   ```swift
   if let sharedDefaults = UserDefaults(suiteName: "group.com.yourname.money-locket") {
       sharedDefaults.set(latestPhotoURLString, forKey: "latestLocketPhotoURL")
       sharedDefaults.set(latestTransactionNotes, forKey: "latestLocketNotes")
   }
   ```
3. **Triggering Widget Refresh**:
   Call WidgetCenter to reload the widget timeline after a user uploads a new post:
   ```swift
   import WidgetKit
   WidgetCenter.shared.reloadAllTimelines()
   ```
4. **Widget View**:
   Within the Widget Extension code, render the fetched image. You can mask it with `HeartShape()` or a standard rounded rectangle depending on the user preference stored in `UserDefaults`.
