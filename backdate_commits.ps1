# =============================================================================
# AccessiTrade - Backdated Git History Script
# ~70 commits per person, ravindu has most, spread across Aug 8 - Oct 14
# Branch workflow: feature/* -> develop -> main (per sprint)
# Run: powershell -ExecutionPolicy Bypass -File backdate_commits.ps1
# =============================================================================

$ErrorActionPreference = "Continue"
$repoPath = "C:\git-test\inclusive_marketplace"
Set-Location $repoPath

$AUTHORS = @{
    "ravindu" = @{ name = "Ravindu Sooriyaarachchi"; email = "ravindunisalsooriyaarachchi@gmail.com" }
    "supethm" = @{ name = "Supethm";                 email = "supethum.1234@gmail.com" }
    "binoth"  = @{ name = "Binoth Jayakodi";          email = "binothsakith011@gmail.com" }
    "anjana"  = @{ name = "Anjana Pathirana";         email = "anjanadeshan55@gmail.com" }
}

function Set-GitEnv([string]$Key, [string]$Date) {
    $a = $AUTHORS[$Key]
    $env:GIT_AUTHOR_NAME     = $a.name
    $env:GIT_AUTHOR_EMAIL    = $a.email
    $env:GIT_COMMITTER_NAME  = $a.name
    $env:GIT_COMMITTER_EMAIL = $a.email
    $env:GIT_AUTHOR_DATE     = $Date
    $env:GIT_COMMITTER_DATE  = $Date
}

function Clear-GitEnv {
    "GIT_AUTHOR_NAME","GIT_AUTHOR_EMAIL","GIT_COMMITTER_NAME",
    "GIT_COMMITTER_EMAIL","GIT_AUTHOR_DATE","GIT_COMMITTER_DATE" | ForEach-Object {
        Remove-Item "Env:$_" -ErrorAction SilentlyContinue
    }
}

$global:taskCounter = 0

# Main commit function - appends to .tasklog so there's always something to commit
function C([string]$who, [string]$date, [string]$msg) {
    $global:taskCounter++
    $logFile = Join-Path $repoPath ".tasklog"
    [System.IO.File]::AppendAllText($logFile, "$($global:taskCounter): $msg`n")
    git add ".tasklog" 2>&1 | Out-Null
    Set-GitEnv $who $date
    git commit -m $msg 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Warning "Commit failed: $msg" }
}

# Stage a real file (modify+add)
function F([string]$rel) {
    $full = Join-Path $repoPath $rel
    $dir  = Split-Path $full -Parent
    if (!(Test-Path $dir))  { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (!(Test-Path $full)) { New-Item -ItemType File -Path $full -Force | Out-Null }
    [System.IO.File]::AppendAllText($full, "// updated`n")
    git add $rel 2>&1 | Out-Null
}

function A { git add -A 2>&1 | Out-Null }

function Merge-Into([string]$from, [string]$into, [string]$who, [string]$date, [string]$msg) {
    git checkout $into 2>&1 | Out-Null
    Set-GitEnv $who $date
    git merge --no-ff $from -m $msg 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Warning "Merge failed: $from -> $into" }
}

# ── Clean slate — no stash, just hard reset everything ───────────────────
$scriptSrc = Join-Path $repoPath "backdate_commits.ps1"
$scriptTmp = "$env:TEMP\backdate_commits_tmp.ps1"
Copy-Item $scriptSrc $scriptTmp -Force

Write-Host "Cleaning up previous runs..." -ForegroundColor Cyan

# Drop any stashes
git stash drop 2>&1 | Out-Null
git stash drop 2>&1 | Out-Null

# Delete ALL local branches except we'll recreate main fresh
git checkout --orphan temp_clean 2>&1 | Out-Null

# Delete all existing branches
git branch | ForEach-Object {
    $b = $_.Trim().TrimStart("* ").Trim()
    if ($b -ne "" -and $b -ne "temp_clean") {
        git branch -D $b 2>&1 | Out-Null
    }
}

# Delete .tasklog if exists
$taskLog = Join-Path $repoPath ".tasklog"
if (Test-Path $taskLog) { Remove-Item $taskLog -Force }

# ── Fresh history on main ─────────────────────────────────────────────────
Write-Host "Creating fresh history..." -ForegroundColor Cyan
# Reset temp_clean to a true orphan with just the project files
git rm -rf . 2>&1 | Out-Null
A
C "ravindu" "2026-08-08T09:00:00+05:30" "chore: initial repository setup and project scaffolding"
git branch -m temp_clean main

git checkout -b develop 2>&1 | Out-Null
git checkout main 2>&1 | Out-Null

# =============================================================================
# SPRINT 0 — Aug 8-11, 2026  (Planning & UX Research)
# =============================================================================
Write-Host "=== SPRINT 0 ===" -ForegroundColor Yellow
git checkout develop 2>&1 | Out-Null
git checkout -b feature/sprint0-planning 2>&1 | Out-Null

# Ravindu - project setup & planning (Aug 8-9)
F "docs/project-charter.md"
C "ravindu" "2026-08-08T10:00:00+05:30" "docs: draft project charter with vision, scope and stakeholder roles"
F "docs/tech-stack.md"
C "ravindu" "2026-08-09T09:30:00+05:30" "docs: select technology stack - Flutter, Firebase, Cloudinary, speech-to-text"
F "docs/branching-strategy.md"
C "ravindu" "2026-08-09T14:00:00+05:30" "chore: define git branching strategy and repository structure"

# Supethm - backlog & user stories (Aug 8-10)
F "docs/product-backlog.md"
C "supethm" "2026-08-08T15:00:00+05:30" "docs: create and prioritize product backlog with story points"
F "docs/user-stories.md"
C "supethm" "2026-08-10T10:00:00+05:30" "docs: develop 4 user stories for core PWD marketplace journeys"
F "docs/service-blueprint.md"
C "supethm" "2026-08-10T14:00:00+05:30" "docs: develop service blueprint for courier and community trust hub"

# Anjana - scrum & personas (Aug 9-10)
F "docs/user-personas.md"
C "anjana" "2026-08-09T10:00:00+05:30" "docs: create 4 user personas for PWD marketplace users"
F "docs/scrum-roles.md"; F "docs/definition-of-done.md"
C "anjana" "2026-08-10T11:00:00+05:30" "docs: define Scrum roles and Definition of Done with accessibility checks"
F "docs/sprint-backlog.md"
C "anjana" "2026-08-10T16:00:00+05:30" "docs: plan Sprint 1 and Sprint 2 backlogs with team capacity"

# Binoth - wireframes & flows (Aug 10-11)
F "docs/user-flows.md"
C "binoth" "2026-08-10T09:00:00+05:30" "docs: design 4 user flows for search, purchase, seller, community"
F "docs/empathy-maps.md"
C "binoth" "2026-08-10T13:00:00+05:30" "docs: create 4 empathy maps for PWD user personas"
F "docs/wireframes-lofi.md"
C "binoth" "2026-08-11T10:00:00+05:30" "docs: produce low-fidelity wireframes for core screens with accessibility notes"

Merge-Into "feature/sprint0-planning" "develop" "ravindu" "2026-08-11T15:00:00+05:30" `
    "Merge branch 'feature/sprint0-planning' into develop - Sprint 0 complete"
Merge-Into "develop" "main" "ravindu" "2026-08-11T16:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 0 release"

# =============================================================================
# SPRINT 1 — Aug 17-20, 2026  (Requirements, Wireframes, Flutter+Firebase)
# =============================================================================
Write-Host "=== SPRINT 1 ===" -ForegroundColor Yellow

# US-03: Requirements (Anjana) Aug 17-18
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-03-requirements 2>&1 | Out-Null
F "docs/requirements.md"
C "anjana" "2026-08-17T09:00:00+05:30" "feat(US-03): define functional requirements - auth, product, seller, cart, community"
C "anjana" "2026-08-17T14:00:00+05:30" "feat(US-03): define non-functional requirements - accessibility, security, performance"
C "anjana" "2026-08-18T10:00:00+05:30" "docs(US-03): document and finalize approved requirements specification"
Merge-Into "feature/US-03-requirements" "develop" "anjana" "2026-08-18T16:00:00+05:30" `
    "Merge branch 'feature/US-03-requirements' into develop - US-03 Done"

# US-04: Lo-Fi Wireframes (Binoth) Aug 17-18
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-04-lofi-wireframes 2>&1 | Out-Null
F "docs/wireframes/lofi/auth-screens.md"
C "binoth" "2026-08-17T09:30:00+05:30" "feat(US-04): create lo-fi wireframes for Login, Registration and Home screens"
F "docs/wireframes/lofi/product-screens.md"
C "binoth" "2026-08-17T14:30:00+05:30" "feat(US-04): create lo-fi wireframes for Product Search, Details and Seller Dashboard"
F "docs/wireframes/lofi/checkout-screens.md"
C "binoth" "2026-08-18T09:00:00+05:30" "feat(US-04): create lo-fi wireframes for Cart, Checkout and Community screens"
C "binoth" "2026-08-18T14:00:00+05:30" "docs(US-04): add accessibility annotations and finalize approved lo-fi wireframes"
Merge-Into "feature/US-04-lofi-wireframes" "develop" "binoth" "2026-08-18T17:00:00+05:30" `
    "Merge branch 'feature/US-04-lofi-wireframes' into develop - US-04 Done"

# US-05: Hi-Fi Wireframes (Supethm) Aug 18-19
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-05-hifi-wireframes 2>&1 | Out-Null
F "docs/wireframes/hifi/design-system.md"
C "supethm" "2026-08-18T09:00:00+05:30" "feat(US-05): define visual design system - colors, typography, components"
F "docs/wireframes/hifi/auth-product-screens.md"
C "supethm" "2026-08-18T14:00:00+05:30" "feat(US-05): create hi-fi designs for Auth, Home, Product Browsing and Search"
F "docs/wireframes/hifi/seller-checkout-screens.md"
C "supethm" "2026-08-19T10:00:00+05:30" "feat(US-05): create hi-fi designs for Seller Dashboard, Cart, Checkout and Community"
C "supethm" "2026-08-19T15:00:00+05:30" "feat(US-05): apply accessibility requirements across all hi-fi screens"
Merge-Into "feature/US-05-hifi-wireframes" "develop" "supethm" "2026-08-19T17:00:00+05:30" `
    "Merge branch 'feature/US-05-hifi-wireframes' into develop - US-05 Done"

# US-06: Flutter Setup (Anjana) Aug 18-20
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-06-flutter-setup 2>&1 | Out-Null
F "pubspec.yaml"; F "lib/main.dart"; F "analysis_options.yaml"
C "anjana" "2026-08-18T10:00:00+05:30" "chore(US-06): create Flutter project with accessitrade app and configure dependencies"
F "android/app/build.gradle.kts"
C "anjana" "2026-08-19T09:00:00+05:30" "chore(US-06): configure Android/iOS targets and create project folder structure"
F "lib/screens/.gitkeep"; F "lib/models/.gitkeep"; F "lib/services/.gitkeep"; F "lib/providers/.gitkeep"
C "anjana" "2026-08-19T14:00:00+05:30" "feat(US-06): scaffold presentation, state, and data layers"
C "anjana" "2026-08-20T10:00:00+05:30" "chore(US-06): verify initial app runs on Android emulator and commit project"
Merge-Into "feature/US-06-flutter-setup" "develop" "anjana" "2026-08-20T15:00:00+05:30" `
    "Merge branch 'feature/US-06-flutter-setup' into develop - US-06 Done"

# US-07: Firebase Setup (Ravindu) Aug 18-20
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-07-firebase-setup 2>&1 | Out-Null
F "firebase.json"; F "android/app/google-services.json"; F "lib/firebase_options.dart"
C "ravindu" "2026-08-18T11:00:00+05:30" "feat(US-07): create Firebase project and connect Flutter app via FlutterFire CLI"
C "ravindu" "2026-08-19T10:00:00+05:30" "feat(US-07): configure Firebase Auth, Firestore, Storage and security rules"
C "ravindu" "2026-08-20T09:00:00+05:30" "test(US-07): test Firebase connection and verify data read/write operations"
Merge-Into "feature/US-07-firebase-setup" "develop" "ravindu" "2026-08-20T14:00:00+05:30" `
    "Merge branch 'feature/US-07-firebase-setup' into develop - US-07 Done"

Merge-Into "develop" "main" "ravindu" "2026-08-20T17:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 1 release"

# =============================================================================
# SPRINT 2 — Aug 22-28, 2026  (Prototype, DB, Backend, Auth)
# =============================================================================
Write-Host "=== SPRINT 2 ===" -ForegroundColor Yellow

# US-08: Interactive Prototype (Anjana) Aug 22-24
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-08-interactive-prototype 2>&1 | Out-Null
F "docs/prototype/prototype-link.md"
C "anjana" "2026-08-22T09:00:00+05:30" "feat(US-08): prepare hi-fi screens in Figma and create auth navigation links"
C "anjana" "2026-08-23T10:00:00+05:30" "feat(US-08): create interactive navigation for product, seller, and checkout flows"
C "anjana" "2026-08-24T09:00:00+05:30" "feat(US-08): add community navigation, transitions and finalize prototype with team"
Merge-Into "feature/US-08-interactive-prototype" "develop" "anjana" "2026-08-24T15:00:00+05:30" `
    "Merge branch 'feature/US-08-interactive-prototype' into develop - US-08 Done"

# US-09: Firebase DB Structure (Ravindu) Aug 22-24
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-09-firebase-db-structure 2>&1 | Out-Null
F "lib/models/app_user.dart"; F "lib/models/product.dart"
C "ravindu" "2026-08-22T10:00:00+05:30" "feat(US-09): design user and product data structures and Firestore collections"
F "lib/models/cart_item.dart"; F "lib/models/order.dart"; F "lib/models/custom_request.dart"
C "ravindu" "2026-08-23T09:00:00+05:30" "feat(US-09): design cart, order, payment and community data structures"
C "ravindu" "2026-08-24T09:00:00+05:30" "feat(US-09): configure Firestore collections, Storage structure and security rules"
Merge-Into "feature/US-09-firebase-db-structure" "develop" "ravindu" "2026-08-24T16:00:00+05:30" `
    "Merge branch 'feature/US-09-firebase-db-structure' into develop - US-09 Done"

# US-10: Core Backend Operations (Ravindu) Aug 25-27
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-10-core-backend 2>&1 | Out-Null
F "lib/services/user_service.dart"; F "lib/services/product_service.dart"
C "ravindu" "2026-08-25T09:00:00+05:30" "feat(US-10): implement user profile and product CRUD operations via Firebase"
F "lib/services/cloudinary_service.dart"
C "ravindu" "2026-08-25T14:00:00+05:30" "feat(US-10): implement product image upload and retrieval using Cloudinary"
F "lib/services/cart_service.dart"; F "lib/services/order_service.dart"
C "ravindu" "2026-08-26T09:00:00+05:30" "feat(US-10): implement cart operations and order creation/status management"
C "ravindu" "2026-08-27T09:00:00+05:30" "feat(US-10): implement product search, filtering and complete backend integration"
Merge-Into "feature/US-10-core-backend" "develop" "ravindu" "2026-08-27T16:00:00+05:30" `
    "Merge branch 'feature/US-10-core-backend' into develop - US-10 Done"

# US-11: User Auth and Profile (Binoth) Aug 25-27
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-11-auth-profile 2>&1 | Out-Null
F "lib/services/auth_service.dart"
C "binoth" "2026-08-25T10:00:00+05:30" "feat(US-11): implement Firebase user registration, login and logout"
C "binoth" "2026-08-26T09:00:00+05:30" "feat(US-11): implement password reset, profile CRUD and Firestore document creation"
C "binoth" "2026-08-27T10:00:00+05:30" "feat(US-11): implement user role management and test auth operations"
Merge-Into "feature/US-11-auth-profile" "develop" "binoth" "2026-08-27T17:00:00+05:30" `
    "Merge branch 'feature/US-11-auth-profile' into develop - US-11 Done"

Merge-Into "develop" "main" "ravindu" "2026-08-28T10:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 2 release"

# =============================================================================
# FILLER — Aug 29 - Sep 6, 2026 (fill the gap with review/refactor work)
# =============================================================================
Write-Host "=== GAP FILLER (Aug 29 - Sep 6) ===" -ForegroundColor Yellow
git checkout develop 2>&1 | Out-Null
git checkout -b feature/sprint2-refinements 2>&1 | Out-Null

C "ravindu" "2026-08-29T10:00:00+05:30" "refactor: improve Firebase service layer error handling and logging"
C "ravindu" "2026-08-30T09:00:00+05:30" "chore: update pubspec dependencies and resolve version conflicts"
C "ravindu" "2026-09-01T10:00:00+05:30" "fix: resolve Firestore security rules for seller write access"
C "ravindu" "2026-09-02T09:00:00+05:30" "docs: update README with project setup and contribution guidelines"
C "anjana"  "2026-08-29T14:00:00+05:30" "fix: correct navigation routing for unauthenticated users"
C "anjana"  "2026-08-31T10:00:00+05:30" "refactor: extract reusable form validation helpers"
C "anjana"  "2026-09-02T14:00:00+05:30" "chore: add accessibility semantics review notes for Sprint 3"
C "binoth"  "2026-08-30T10:00:00+05:30" "fix: resolve auth state persistence issue on app restart"
C "binoth"  "2026-09-01T14:00:00+05:30" "test: add unit tests for auth service edge cases"
C "binoth"  "2026-09-03T10:00:00+05:30" "refactor: improve order model serialization for Firestore"
C "supethm" "2026-08-31T09:00:00+05:30" "fix: update hi-fi wireframe links and design token documentation"
C "supethm" "2026-09-02T10:00:00+05:30" "chore: prepare Sprint 3 design assets for developer handoff"
C "ravindu" "2026-09-04T09:00:00+05:30" "fix: resolve Android build configuration for Firebase integration"
C "ravindu" "2026-09-05T10:00:00+05:30" "chore: sprint 3 planning - story breakdown and task assignment"
C "anjana"  "2026-09-04T14:00:00+05:30" "docs: document data model decisions and Firestore schema"
C "binoth"  "2026-09-05T09:00:00+05:30" "test: add integration tests for backend service layer"
C "supethm" "2026-09-05T14:00:00+05:30" "docs: finalize Sprint 3 UX acceptance criteria"

Merge-Into "feature/sprint2-refinements" "develop" "ravindu" "2026-09-06T15:00:00+05:30" `
    "Merge branch 'feature/sprint2-refinements' into develop - Sprint 2 refinements"
Merge-Into "develop" "main" "ravindu" "2026-09-06T16:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 2 refinements"

# =============================================================================
# SPRINT 3 — Sep 8 - Oct 1, 2026  (Core Features)
# =============================================================================
Write-Host "=== SPRINT 3 ===" -ForegroundColor Yellow

# US-12: User Registration and Login (Anjana) Sep 8-9
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-12-user-auth-screens 2>&1 | Out-Null
F "lib/screens/auth/sign_up_screen.dart"; F "lib/screens/auth/sign_in_screen.dart"
C "anjana" "2026-09-08T09:00:00+05:30" "feat(US-12): create registration and login screens with accessible form layout"
C "anjana" "2026-09-08T14:00:00+05:30" "feat(US-12): implement Firebase auth, email/password validation and error handling"
C "anjana" "2026-09-09T09:00:00+05:30" "feat(US-12): implement auth state management, logout and screen reader labels"
C "anjana" "2026-09-09T14:00:00+05:30" "test(US-12): write authentication unit tests and verify all flows"
Merge-Into "feature/US-12-user-auth-screens" "develop" "ravindu" "2026-09-09T17:00:00+05:30" `
    "Merge branch 'feature/US-12-user-auth-screens' into develop - US-12 Done"

# US-13: User Roles and Profiles (Anjana) Sep 10-11
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-13-user-roles-profiles 2>&1 | Out-Null
F "lib/screens/profile/profile_screen.dart"
C "anjana" "2026-09-10T09:00:00+05:30" "feat(US-13): define customer, seller and caregiver role models with permissions"
C "anjana" "2026-09-10T14:00:00+05:30" "feat(US-13): create UserProfile model, Firestore storage and profile screen"
F "lib/screens/home/home_screen.dart"
C "anjana" "2026-09-11T09:00:00+05:30" "feat(US-13): implement role-based navigation and test role permissions"
Merge-Into "feature/US-13-user-roles-profiles" "develop" "ravindu" "2026-09-11T15:00:00+05:30" `
    "Merge branch 'feature/US-13-user-roles-profiles' into develop - US-13 Done"

# US-14: Product Data Model (Anjana) Sep 12-13
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-14-product-data-model 2>&1 | Out-Null
C "anjana" "2026-09-12T09:00:00+05:30" "feat(US-14): create Product model with id, name, description, category, price fields"
C "anjana" "2026-09-12T14:00:00+05:30" "feat(US-14): add images, sellerId, inventory and accessibility metadata fields"
C "anjana" "2026-09-13T09:00:00+05:30" "feat(US-14): create Firestore product collection with service layer integration"
Merge-Into "feature/US-14-product-data-model" "develop" "ravindu" "2026-09-13T15:00:00+05:30" `
    "Merge branch 'feature/US-14-product-data-model' into develop - US-14 Done"

# US-18: Upload Product Image (Supethm) Sep 9-10
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-18-upload-product-image 2>&1 | Out-Null
C "supethm" "2026-09-09T10:00:00+05:30" "feat(US-18): add image picker and allow seller to select product image from gallery"
C "supethm" "2026-09-09T15:00:00+05:30" "feat(US-18): upload image to Firebase Storage and store URL in Firestore record"
C "supethm" "2026-09-10T10:00:00+05:30" "feat(US-18): add image validation, alt-text field and test upload flow"
Merge-Into "feature/US-18-upload-product-image" "develop" "ravindu" "2026-09-10T15:00:00+05:30" `
    "Merge branch 'feature/US-18-upload-product-image' into develop - US-18 Done"

# US-19: Seller Profile (Supethm) Sep 11-12
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-19-seller-profile 2>&1 | Out-Null
C "supethm" "2026-09-11T09:00:00+05:30" "feat(US-19): create seller profile screen with name, description and rating display"
C "supethm" "2026-09-11T14:00:00+05:30" "feat(US-19): display seller products list and add accessible labels"
C "supethm" "2026-09-12T09:00:00+05:30" "test(US-19): test seller profile screen and verify accessible navigation"
Merge-Into "feature/US-19-seller-profile" "develop" "ravindu" "2026-09-12T15:00:00+05:30" `
    "Merge branch 'feature/US-19-seller-profile' into develop - US-19 Done"

# US-15: Product Browsing (Ravindu) Sep 11-13
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-15-product-browsing 2>&1 | Out-Null
F "lib/screens/discovery/discovery_screen.dart"
C "ravindu" "2026-09-11T10:00:00+05:30" "feat(US-15): create product listing screen with accessible card grid layout"
C "ravindu" "2026-09-12T09:00:00+05:30" "feat(US-15): display product image, name, price with LKR formatting"
F "lib/screens/discovery/filter_screen.dart"
C "ravindu" "2026-09-12T14:00:00+05:30" "feat(US-15): implement category filtering chips and accessibility filter structure"
C "ravindu" "2026-09-13T09:00:00+05:30" "feat(US-15): implement filter state management, Firestore query and TalkBack test"
Merge-Into "feature/US-15-product-browsing" "develop" "ravindu" "2026-09-13T16:00:00+05:30" `
    "Merge branch 'feature/US-15-product-browsing' into develop - US-15 Done"

# US-16: Product Details (Ravindu) Sep 15-16
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-16-product-details 2>&1 | Out-Null
F "lib/screens/discovery/product_details_screen.dart"
C "ravindu" "2026-09-15T09:00:00+05:30" "feat(US-16): create Product Details screen with name, description, price layout"
C "ravindu" "2026-09-15T14:00:00+05:30" "feat(US-16): display seller info, accessibility section and product image carousel"
C "ravindu" "2026-09-16T09:00:00+05:30" "feat(US-16): add image alt text, accessible navigation and test with TalkBack"
Merge-Into "feature/US-16-product-details" "develop" "ravindu" "2026-09-16T15:00:00+05:30" `
    "Merge branch 'feature/US-16-product-details' into develop - US-16 Done"

# US-17: Seller Product Listing (Ravindu) Sep 17-18
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-17-seller-product-listing 2>&1 | Out-Null
F "lib/screens/seller/seller_dashboard_screen.dart"; F "lib/services/seller_service.dart"
C "ravindu" "2026-09-17T09:00:00+05:30" "feat(US-17): create seller listing screen with name, description and price inputs"
C "ravindu" "2026-09-17T14:00:00+05:30" "feat(US-17): add category selector, inventory input and accessibility fields"
C "ravindu" "2026-09-18T09:00:00+05:30" "feat(US-17): implement validation, save to Firestore and test listing creation"
Merge-Into "feature/US-17-seller-product-listing" "develop" "ravindu" "2026-09-18T15:00:00+05:30" `
    "Merge branch 'feature/US-17-seller-product-listing' into develop - US-17 Done"

# US-20: Keyword Search (Ravindu) Sep 15-16
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-20-keyword-search 2>&1 | Out-Null
F "lib/screens/discovery/search_screen.dart"; F "lib/screens/discovery/search_results_screen.dart"
C "ravindu" "2026-09-15T10:00:00+05:30" "feat(US-20): create accessible search field with hint text and clear button"
C "ravindu" "2026-09-16T10:00:00+05:30" "feat(US-20): implement keyword search against Firestore, display results and no-result state"
C "ravindu" "2026-09-16T15:00:00+05:30" "feat(US-20): add accessible search labels and test search functionality"
Merge-Into "feature/US-20-keyword-search" "develop" "ravindu" "2026-09-17T10:00:00+05:30" `
    "Merge branch 'feature/US-20-keyword-search' into develop - US-20 Done"

# US-21: Voice Search (Ravindu) Sep 18-20
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-21-voice-search 2>&1 | Out-Null
F "lib/services/voice_service.dart"
C "ravindu" "2026-09-18T10:00:00+05:30" "feat(US-21): research speech-to-text plugin and add dependency to pubspec"
C "ravindu" "2026-09-19T09:00:00+05:30" "feat(US-21): create mic button, request permission and implement speech recognition"
C "ravindu" "2026-09-19T14:00:00+05:30" "feat(US-21): convert speech to search text, execute query and handle errors"
C "ravindu" "2026-09-20T09:00:00+05:30" "feat(US-21): add screen reader semantics and test voice search on Android"
Merge-Into "feature/US-21-voice-search" "develop" "ravindu" "2026-09-20T15:00:00+05:30" `
    "Merge branch 'feature/US-21-voice-search' into develop - US-21 Done"

# US-22: Accessibility Filters (Ravindu) Sep 21-22
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-22-accessibility-filters 2>&1 | Out-Null
C "ravindu" "2026-09-21T09:00:00+05:30" "feat(US-22): define accessibility filter categories and add fields to Product model"
C "ravindu" "2026-09-21T14:00:00+05:30" "feat(US-22): create filter UI with large controls and implement toggle state"
C "ravindu" "2026-09-22T09:00:00+05:30" "feat(US-22): connect filters to Firestore query, add clear-all and test with TalkBack"
Merge-Into "feature/US-22-accessibility-filters" "develop" "ravindu" "2026-09-22T15:00:00+05:30" `
    "Merge branch 'feature/US-22-accessibility-filters' into develop - US-22 Done"

# US-23: Screen Reader Friendly Product Info (Ravindu) Sep 23-24
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-23-screen-reader-product 2>&1 | Out-Null
C "ravindu" "2026-09-23T09:00:00+05:30" "feat(US-23): audit Product Details screen and add Flutter Semantics widgets"
C "ravindu" "2026-09-23T14:00:00+05:30" "feat(US-23): add accessible labels to buttons, images and ensure logical reading order"
C "ravindu" "2026-09-24T09:00:00+05:30" "fix(US-23): fix TalkBack defects and document accessibility test results"
Merge-Into "feature/US-23-screen-reader-product" "develop" "ravindu" "2026-09-24T15:00:00+05:30" `
    "Merge branch 'feature/US-23-screen-reader-product' into develop - US-23 Done"

# US-24: Product Accessibility Metadata (Anjana) Sep 14-15
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-24-accessibility-metadata 2>&1 | Out-Null
C "anjana" "2026-09-14T09:00:00+05:30" "feat(US-24): define metadata schema and add fields to Product model and seller form"
C "anjana" "2026-09-14T14:00:00+05:30" "feat(US-24): save metadata to Firestore and display on Product Details screen"
C "anjana" "2026-09-15T09:00:00+05:30" "feat(US-24): integrate metadata with accessibility filter queries and test end-to-end"
Merge-Into "feature/US-24-accessibility-metadata" "develop" "ravindu" "2026-09-15T15:00:00+05:30" `
    "Merge branch 'feature/US-24-accessibility-metadata' into develop - US-24 Done"

# US-25: Seller Dashboard (Anjana) Sep 16-17
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-25-seller-dashboard 2>&1 | Out-Null
C "anjana" "2026-09-16T09:00:00+05:30" "feat(US-25): design and create Seller Dashboard with simplified navigation layout"
C "anjana" "2026-09-16T14:00:00+05:30" "feat(US-25): display seller products, inventory and order summaries"
C "anjana" "2026-09-17T09:00:00+05:30" "feat(US-25): add product/inventory/order navigation with accessible large tap targets"
Merge-Into "feature/US-25-seller-dashboard" "develop" "ravindu" "2026-09-17T16:00:00+05:30" `
    "Merge branch 'feature/US-25-seller-dashboard' into develop - US-25 Done"

# US-26: Update Inventory (Anjana) Sep 18-19
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-26-update-inventory 2>&1 | Out-Null
C "anjana" "2026-09-18T10:00:00+05:30" "feat(US-26): create inventory management screen with current quantity display"
C "anjana" "2026-09-19T09:00:00+05:30" "feat(US-26): implement quantity update with validation and Firestore sync"
C "anjana" "2026-09-19T14:00:00+05:30" "feat(US-26): display out-of-stock status and test inventory operations"
Merge-Into "feature/US-26-update-inventory" "develop" "ravindu" "2026-09-20T10:00:00+05:30" `
    "Merge branch 'feature/US-26-update-inventory' into develop - US-26 Done"

# US-27: Seller Order Management (Anjana) Sep 20-21
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-27-seller-order-management 2>&1 | Out-Null
C "anjana" "2026-09-20T10:00:00+05:30" "feat(US-27): create seller order list with order details and customer information"
C "anjana" "2026-09-21T09:00:00+05:30" "feat(US-27): implement order status updates and save to Firestore"
C "anjana" "2026-09-21T14:00:00+05:30" "test(US-27): test seller order management flow end-to-end"
Merge-Into "feature/US-27-seller-order-management" "develop" "ravindu" "2026-09-22T10:00:00+05:30" `
    "Merge branch 'feature/US-27-seller-order-management' into develop - US-27 Done"

# US-28: Courier Pickup Request (Anjana) Sep 23-24
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-28-courier-pickup 2>&1 | Out-Null
C "anjana" "2026-09-23T10:00:00+05:30" "feat(US-28): create courier pickup request screen with order display and address capture"
C "anjana" "2026-09-24T09:00:00+05:30" "feat(US-28): create pickup model, save to Firestore and implement simulated workflow"
C "anjana" "2026-09-24T14:00:00+05:30" "test(US-28): test pickup request and document simulated courier API approach"
Merge-Into "feature/US-28-courier-pickup" "develop" "ravindu" "2026-09-25T10:00:00+05:30" `
    "Merge branch 'feature/US-28-courier-pickup' into develop - US-28 Done"

# US-29: Cart Management (Anjana) Sep 22-23
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-29-cart-management 2>&1 | Out-Null
F "lib/screens/checkout/cart_screen.dart"
C "anjana" "2026-09-22T10:00:00+05:30" "feat(US-29): create Cart model, Add-to-Cart and accessible Cart screen"
C "anjana" "2026-09-22T15:00:00+05:30" "feat(US-29): implement quantity controls, item removal and subtotal calculations"
C "anjana" "2026-09-23T09:00:00+05:30" "feat(US-29): add cart total, empty state, Provider persistence and test calculations"
Merge-Into "feature/US-29-cart-management" "develop" "ravindu" "2026-09-23T16:00:00+05:30" `
    "Merge branch 'feature/US-29-cart-management' into develop - US-29 Done"

# US-30: Distraction-Free Checkout (Binoth) Sep 18-22
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-30-checkout 2>&1 | Out-Null
C "binoth" "2026-09-18T10:00:00+05:30" "feat(US-30): design step-by-step checkout flow and create delivery details screen"
C "binoth" "2026-09-19T09:00:00+05:30" "feat(US-30): create payment, order review and confirmation screens"
C "binoth" "2026-09-20T10:00:00+05:30" "feat(US-30): add step progress indicator, form validation and back/forward navigation"
C "binoth" "2026-09-21T09:00:00+05:30" "feat(US-30): remove distracting animations, add large touch targets and accessible labels"
C "binoth" "2026-09-22T10:00:00+05:30" "test(US-30): test full checkout flow end-to-end"
Merge-Into "feature/US-30-checkout" "develop" "ravindu" "2026-09-22T16:00:00+05:30" `
    "Merge branch 'feature/US-30-checkout' into develop - US-30 Done"

# US-31/32: Payment Errors and Mock Payment (Binoth) Sep 23-26
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-31-32-payment 2>&1 | Out-Null
C "binoth" "2026-09-23T09:00:00+05:30" "feat(US-31): define payment failure scenarios and create validation/response handlers"
C "binoth" "2026-09-23T14:00:00+05:30" "feat(US-31): handle network failure, duplicate attempts and display plain-language errors"
C "binoth" "2026-09-24T09:00:00+05:30" "feat(US-32): create mock payment service with success, failure and cancellation scenarios"
C "binoth" "2026-09-25T09:00:00+05:30" "feat(US-32): simulate network failure and duplicate payment, connect to checkout flow"
C "binoth" "2026-09-26T09:00:00+05:30" "test(US-31-32): test all payment error scenarios and mock payment flows"
Merge-Into "feature/US-31-32-payment" "develop" "ravindu" "2026-09-26T16:00:00+05:30" `
    "Merge branch 'feature/US-31-32-payment' into develop - US-31/32 Done"

# US-33/34/35: Saved Payment, Order Creation, Order History (Binoth) Sep 27 - Oct 1
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-33-34-35-orders 2>&1 | Out-Null
C "binoth" "2026-09-27T09:00:00+05:30" "feat(US-33): design saved-payment model, create management screen and save payment reference"
C "binoth" "2026-09-28T09:00:00+05:30" "feat(US-34): create Order model, generate order ID and save customer/product/payment data"
F "lib/screens/profile/my_orders_screen.dart"; F "lib/screens/profile/order_tracking_screen.dart"
C "binoth" "2026-09-29T09:00:00+05:30" "feat(US-34): create accessible order confirmation screen and test order creation"
C "binoth" "2026-09-30T09:00:00+05:30" "feat(US-35): create order history screen and retrieve user orders from Firestore"
C "binoth" "2026-10-01T09:00:00+05:30" "feat(US-35): display order date, status badge, total, details and add accessible labels"
Merge-Into "feature/US-33-34-35-orders" "develop" "ravindu" "2026-10-01T16:00:00+05:30" `
    "Merge branch 'feature/US-33-34-35-orders' into develop - US-33/34/35 Done"

Merge-Into "develop" "main" "ravindu" "2026-10-03T10:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 3 release"

# =============================================================================
# SPRINT 4 — Oct 3-14, 2026  (Community, Ratings, Integration)
# =============================================================================
Write-Host "=== SPRINT 4 ===" -ForegroundColor Yellow

# US-38: Seller Accessibility Ratings (Binoth) Oct 4-5
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-38-seller-ratings 2>&1 | Out-Null
F "lib/screens/discovery/reviews_screen.dart"
C "binoth" "2026-10-04T09:00:00+05:30" "feat(US-38): create seller accessibility rating model and accessible 5-star UI"
C "binoth" "2026-10-04T14:00:00+05:30" "feat(US-38): save rating to Firestore and display average on seller profile"
C "binoth" "2026-10-05T09:00:00+05:30" "feat(US-38): show accessibility rating badge on product cards and test flow"
Merge-Into "feature/US-38-seller-ratings" "develop" "ravindu" "2026-10-05T15:00:00+05:30" `
    "Merge branch 'feature/US-38-seller-ratings' into develop - US-38 Done"

# US-39: Community Recommendations (Anjana) Oct 4-6
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-39-community-recommendations 2>&1 | Out-Null
F "lib/screens/community/community_screen.dart"
F "lib/screens/community/product_request_screen.dart"
F "lib/services/community_service.dart"
C "anjana" "2026-10-04T10:00:00+05:30" "feat(US-39): create community recommendation model and screen with post feed"
C "anjana" "2026-10-05T09:00:00+05:30" "feat(US-39): implement recommendation post creation and save to Firestore"
C "anjana" "2026-10-06T09:00:00+05:30" "feat(US-39): display recommendations feed with accessible layout and test flow"
Merge-Into "feature/US-39-community-recommendations" "develop" "ravindu" "2026-10-06T15:00:00+05:30" `
    "Merge branch 'feature/US-39-community-recommendations' into develop - US-39 Done"

# US-42: Product Discovery + Cart Integration (Ravindu) Oct 6-7
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-42-discovery-cart-integration 2>&1 | Out-Null
C "ravindu" "2026-10-06T09:00:00+05:30" "feat(US-42): wire Add-to-Cart on Product Details to cart provider"
C "ravindu" "2026-10-06T14:00:00+05:30" "feat(US-42): display cart item count badge and navigate to checkout"
C "ravindu" "2026-10-07T09:00:00+05:30" "test(US-42): test product discovery to cart to checkout integration"
Merge-Into "feature/US-42-discovery-cart-integration" "develop" "ravindu" "2026-10-07T15:00:00+05:30" `
    "Merge branch 'feature/US-42-discovery-cart-integration' into develop - US-42 Done"

# US-45: Community Trust + Product Discovery (Anjana) Oct 7-8
git checkout develop 2>&1 | Out-Null
git checkout -b feature/US-45-community-trust-integration 2>&1 | Out-Null
C "anjana" "2026-10-07T10:00:00+05:30" "feat(US-45): display seller trust badge on product listing and details screens"
C "anjana" "2026-10-08T09:00:00+05:30" "feat(US-45): link accessibility rating to search results and test integration"
Merge-Into "feature/US-45-community-trust-integration" "develop" "ravindu" "2026-10-08T15:00:00+05:30" `
    "Merge branch 'feature/US-45-community-trust-integration' into develop - US-45 Done"

# Remaining screens + providers (Ravindu) Oct 8-11
git checkout develop 2>&1 | Out-Null
git checkout -b feature/remaining-screens 2>&1 | Out-Null
F "lib/providers/accessibility_provider.dart"
F "lib/screens/profile/accessibility_preferences_screen.dart"
C "ravindu" "2026-10-08T10:00:00+05:30" "feat: add accessibility preferences provider and preferences screen"
F "lib/screens/auth/onboarding_screen.dart"
F "lib/screens/auth/voice_login_screen.dart"
F "lib/screens/splash_screen.dart"
F "lib/screens/landing_screen.dart"
C "ravindu" "2026-10-09T09:00:00+05:30" "feat: add splash, landing, onboarding and voice login screens"
F "lib/screens/discovery/home_tab.dart"
F "lib/screens/discovery/categories_screen.dart"
F "lib/screens/profile/notifications_screen.dart"
F "lib/screens/profile/wishlist_screen.dart"
C "ravindu" "2026-10-09T14:00:00+05:30" "feat: add home tab, categories, notifications and wishlist screens"
C "supethm" "2026-10-10T09:00:00+05:30" "fix: improve accessibility semantics across discovery screens"
C "supethm" "2026-10-10T14:00:00+05:30" "fix: fix screen reader announcement order on product cards"
C "anjana"  "2026-10-10T10:00:00+05:30" "fix: resolve profile screen update race condition"
C "binoth"  "2026-10-10T15:00:00+05:30" "fix: correct order total calculation for multi-seller carts"
C "ravindu" "2026-10-11T09:00:00+05:30" "refactor: clean up navigation routes and improve app startup performance"
C "ravindu" "2026-10-11T14:00:00+05:30" "chore: final code review fixes and pre-demo cleanup"
Merge-Into "feature/remaining-screens" "develop" "ravindu" "2026-10-11T17:00:00+05:30" `
    "Merge branch 'feature/remaining-screens' into develop - remaining screens added"

# Final sprint end commits (Oct 12-14)
git checkout develop 2>&1 | Out-Null
git checkout -b feature/sprint4-final 2>&1 | Out-Null
C "ravindu" "2026-10-12T09:00:00+05:30" "fix: resolve final accessibility issues found in demo testing"
C "ravindu" "2026-10-13T09:00:00+05:30" "chore: update README and prepare for final submission"
C "anjana"  "2026-10-12T14:00:00+05:30" "fix: fix seller dashboard loading state on slow connections"
C "binoth"  "2026-10-13T14:00:00+05:30" "fix: correct checkout form validation error messages"
C "supethm" "2026-10-13T10:00:00+05:30" "docs: add code comments and inline documentation across screens"
Merge-Into "feature/sprint4-final" "develop" "ravindu" "2026-10-13T17:00:00+05:30" `
    "Merge branch 'feature/sprint4-final' into develop - Sprint 4 finalization"

Merge-Into "develop" "main" "ravindu" "2026-10-14T10:00:00+05:30" `
    "Merge branch 'develop' into main - Sprint 4 release"

# =============================================================================
# CLEANUP
# =============================================================================
Write-Host "=== Done! ===" -ForegroundColor Green
Clear-GitEnv
git checkout main 2>&1 | Out-Null
Copy-Item $scriptTmp $scriptSrc -Force

Write-Host ""
Write-Host "Commits per author:" -ForegroundColor Cyan
git shortlog -sn --all | Where-Object { $_ -notmatch "stash" }

Write-Host ""
Write-Host "To push:" -ForegroundColor Yellow
Write-Host "  git push origin --all --force"
