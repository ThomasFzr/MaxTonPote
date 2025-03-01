# MAX TON POTE

MAX TON POTE is a Flutter application that allows users to connect with friends, view their locations on a map, and manage their profiles.

## Features

- **Add Friends**: Search for and add friends based on proximity.
- **View Friends**: See a list of your friends and their distances from your current location.
- **Map Integration**: View your friends' locations on a Mapbox map.
- **Profile Management**: Manage your profile and connect with Google for authentication.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Mapbox Access Token: [Get a Mapbox token](https://account.mapbox.com/access-tokens/)
- Supabase Account: [Sign up for Supabase](https://supabase.io/)

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/ThomasFzr/MaxTonPote.git
    cd MaxTonPote
    ```

2. Install dependencies:
    ```sh
    flutter pub get
    ```

3. Set up environment variables:
    - Create a `.env` file in the root directory.
    - Add your Mapbox token and Supabase credentials:
      ```
      SK_MAPBOX_TOKEN=your_mapbox_token
      SUPABASE_URL=your_supabase_url
      SUPABASE_API_KEY=your_supabase_api_key
      ```

4. Run the application:
    ```sh
    flutter run
    ```

## Usage

- **Home Screen**: View a list of friends and their distances.
- **Map Screen**: See friends' locations on a map.
- **Profile Screen**: Manage your profile and sign in with Google.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Mapbox Documentation](https://docs.mapbox.com/)
- [Supabase Documentation](https://supabase.io/docs)

For any issues or contributions, please refer to the [GitHub repository](https://github.com/yourusername/flutter_app_test).

