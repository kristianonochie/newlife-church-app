# YouTube Integration Setup

The Watch page now automatically fetches and displays videos from your YouTube channel. To enable this feature, follow these steps:

## Step 1: Get YouTube API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing one)
3. Enable the **YouTube Data API v3**:
   - Click "Enable APIs and Services"
   - Search for "YouTube Data API v3"
   - Click "Enable"
4. Create API credentials:
   - Go to "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the API key

## Step 2: Get Your YouTube Channel ID

1. Go to your YouTube channel
2. Click your profile icon → "Create a channel" or "Your channel"
3. Go to "Settings" → "Channel" → "Basic Info"
4. Copy your Channel ID (format: `UC...`)
   - Or find it in the URL: `youtube.com/channel/YOUR_CHANNEL_ID`

## Step 3: Configure the Watch Screen

Edit `lib/screens/watch/watch_screen.dart` and replace:

```dart
final _youtubeService = YouTubeService(
  apiKey: 'YOUR_YOUTUBE_API_KEY_HERE', // TODO: Add your API key
  channelId: 'UCYourChannelIDHere', // TODO: Add your channel ID
);
```

With your actual values:

```dart
final _youtubeService = YouTubeService(
  apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxx', // Your API key
  channelId: 'UCxxxxxxxxxxxxxxxXXX', // Your channel ID
);
```

## Features

✅ **Automatic Video Fetching**: Pulls the 10 most recent videos from your channel
✅ **Video Thumbnails**: Displays thumbnail images for each video
✅ **Live Video Support**: Detects and displays live streams
✅ **In-App Playback**: Videos play directly in the app
✅ **Published Dates**: Shows when each video was published
✅ **Channel Link**: Users can visit your channel directly

## Fallback

If you don't configure the API key, the app will use fallback placeholder videos from the content service. Once configured, it will automatically fetch your latest videos.

## Troubleshooting

- **API Key Errors**: Ensure the API key has YouTube Data API v3 enabled
- **Channel ID Issues**: Make sure it's the correct format (starts with "UC")
- **No Videos Showing**: Check that your YouTube account has published videos
- **Rate Limiting**: YouTube API has rate limits (10,000 quota units/day for free tier)

## Security Note

For production, consider storing the API key in a secure backend or Firebase Realtime Database instead of hardcoding it in the app.
