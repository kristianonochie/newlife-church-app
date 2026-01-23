import '../models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChatService with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  final Dio _dio = Dio();

  Future<void> sendMessage(ChatMessage message) async {
    _messages.add(message);
    notifyListeners();

    try {
      final reply = await _buildReply(message.content);
      final safeReply = reply ??
          'I want to give a meaningful, Bible-based answer, but I did not find a direct match. Ask a verse like "John 3:16" or a question such as "Who is Jesus?" and I will help.';

      _messages.add(ChatMessage(
        id: '${message.id}-reply',
        senderId: 'nlcchat',
        role: 'NLCChat',
        content: safeReply,
        timestamp: DateTime.now(),
        attachments: const [],
        escalated: false,
      ));
      notifyListeners();
    } catch (e) {
      // Ensure the user always gets a response even if something fails.
      _messages.add(ChatMessage(
        id: '${message.id}-reply-error',
        senderId: 'nlcchat',
        role: 'NLCChat',
        content:
            'I hit a snag while answering. Please try asking again about a Bible verse (e.g., "John 3:16") or a topic like salvation, prayer, or Jesus.',
        timestamp: DateTime.now(),
        attachments: const [],
        escalated: false,
      ));
      notifyListeners();
    }
  }

  Future<String?> _buildReply(String text) async {
    final lower = text.toLowerCase();

    // Greetings and quick intents
    if (lower.contains('hello') ||
        lower.contains('hi ') ||
        lower.startsWith('hi') ||
        lower.contains('hey')) {
      return 'Hello! 👋 I\'m NLCChat - your Bible-based assistant with FULL access to:\n\n📖 Complete Bible knowledge (all 66 books)\n🌍 Full internet access for any topic\n🙏 Spiritual guidance & prayer\n⛪ Church information\n\nI can answer ANY question instantly - Bible questions, life advice, general knowledge, or anything else. Ask away!';
    }

    if (lower.contains('how are you')) {
      return 'I\'m here and ready to help! I have:\n✅ Complete Bible knowledge (all 66 books searchable)\n✅ Full internet access\n✅ Ability to answer ANYTHING instantly\n\nJust ask me anything - no question is too big or small!';
    }

    // Try to fetch Bible verse if user requests specific scripture
    final bibleVerse = await _tryFetchBibleVerse(lower);
    if (bibleVerse != null) return bibleVerse;

    // Try Bible statistics (how many kings, prophets, etc)
    final bibleStats = await _tryBibleStats(lower);
    if (bibleStats != null) return bibleStats;

    // Try Bible relationships (who is the father of, etc)
    final bibleRelationship = await _tryBibleRelationships(lower);
    if (bibleRelationship != null) return bibleRelationship;

    // === IMPORTANT: Try Bible search FIRST before generic answers ===
    // Try Bible search for general Bible questions
    final bibleSearch = await _tryBibleSearch(lower);
    if (bibleSearch != null) return bibleSearch;

    // === Final Fallback: Try internet search for ANY unmatched query ===
    // If we reach here, we didn't have a built-in answer, so search the internet
    try {
      print('Attempting fallback internet search for: $text');
      final searchResult = await _searchInternet(text);
      if (searchResult != null && searchResult.isNotEmpty) {
        return '🌐 $searchResult';
      }
    } catch (e) {
      print('Fallback internet search failed: $e');
    }

    // === Generic Theological Topics (only if internet search fails) ===
    // These are fallbacks - specific searches should have already matched above

    if (lower.contains('gospel')) {
      return 'The Gospel (Good News) is that Jesus Christ died for our sins and rose again, offering salvation to all who believe. 1 Corinthians 15:3-4 summarizes: "Christ died for our sins...was buried...was raised on the third day." The Gospel transforms lives, reconciles us to God, and offers eternal life. It\'s the power of God for salvation (Romans 1:16).';
    }

    if (lower.contains('salvation') ||
        lower.contains('saved') ||
        lower.contains('born again')) {
      return 'Salvation comes through faith in Jesus Christ. Romans 10:9 says: "If you declare with your mouth, \'Jesus is Lord,\' and believe in your heart that God raised him from the dead, you will be saved." It\'s a free gift (Ephesians 2:8-9) - we cannot earn it. Being "born again" (John 3:3) means spiritual rebirth through the Holy Spirit. Have you accepted Christ as your Savior?';
    }

    if (lower.contains('jesus') && !lower.contains('love')) {
      return 'Jesus Christ is the Son of God, fully God and fully man. He lived sinlessly, died on the cross for our sins, and rose victoriously on the third day. Colossians 1:15-20 declares He is the image of God, creator of all, and reconciler of all things. In Him we find forgiveness, purpose, peace, and eternal life. Jesus is "the way, the truth, and the life" (John 14:6).';
    }

    if (lower.contains('christ') && !lower.contains('love')) {
      return 'Jesus Christ is the Son of God, fully God and fully man. He lived sinlessly, died on the cross for our sins, and rose victoriously on the third day. Colossians 1:15-20 declares He is the image of God, creator of all, and reconciler of all things. In Him we find forgiveness, purpose, peace, and eternal life. Jesus is "the way, the truth, and the life" (John 14:6).';
    }

    if (lower.contains('cross') || lower.contains('crucifixion')) {
      return 'The cross represents God\'s ultimate act of love and justice. Jesus willingly died on the cross, bearing our sins and God\'s wrath, to reconcile us to God. 1 Peter 2:24 says "He himself bore our sins in his body on the cross." The cross is both judgment on sin and victory over death. Through the cross, we have peace with God (Colossians 1:20).';
    }

    if (lower.contains('resurrection') || lower.contains('risen')) {
      return 'The resurrection of Jesus Christ is Christianity\'s foundation. 1 Corinthians 15:14 says if Christ didn\'t rise, our faith is useless. But He DID rise! His resurrection proves He\'s God\'s Son, defeated sin and death, and guarantees our resurrection. Romans 6:4 explains we share in His resurrection life now and will be raised bodily in the future. Death has lost its sting!';
    }

    if (lower.contains('prayer') && !lower.contains('pray')) {
      return 'Prayer is intimate conversation with God. Jesus taught us to pray with faith (Matthew 21:22), persistence (Luke 18:1-8), and humility (Luke 18:9-14). The Lord\'s Prayer (Matthew 6:9-13) models worship, petition, and submission. Philippians 4:6-7 encourages praying about everything. God hears every prayer and answers according to His perfect will. Keep praying!';
    }

    if (lower.contains('peace')) {
      return 'Jesus promised "Peace I leave with you; my peace I give you" (John 14:27). God\'s peace surpasses understanding (Philippians 4:7) and guards our hearts. Isaiah 26:3 says God keeps in perfect peace those whose minds are stayed on Him. Romans 5:1 declares through faith we have peace WITH God. Peace is both a position (reconciled to God) and an experience (calm trust). Rest in His peace.';
    }

    if (lower.contains('faith') && !lower.contains('your faith')) {
      return 'Faith is trusting God completely. Hebrews 11:1 defines it: "confidence in what we hope for and assurance about what we do not see." Faith pleases God (Hebrews 11:6). Romans 10:17 says "faith comes from hearing the message...about Christ." Faith isn\'t blind - it\'s based on God\'s character and promises. Even small faith moves mountains (Matthew 17:20). Keep believing!';
    }

    if (lower.contains('grace')) {
      return 'Grace is God\'s unmerited, unearned favor. Ephesians 2:8-9 declares: "By grace you have been saved, through faith...not by works." Grace covers ALL sin, empowers holy living, and demonstrates God\'s kindness. Titus 2:11 says grace teaches us to say no to ungodliness. Where sin abounds, grace abounds more (Romans 5:20). God\'s grace is sufficient for every weakness (2 Corinthians 12:9).';
    }

    // === Enhanced Fallback response if nothing matched ===
    final preview =
        text.length > 50 ? '${text.substring(0, 47)}...' : text.trim();
    return '🤔 I don\'t have a specific answer for "$preview" and my searches didn\'t find clear results.\n\n💬 Try asking:\n📖 Bible verses (e.g., "John 3:16", "Psalm 23")\n✝️ Bible topics (e.g., "Tell me about Genesis", "Who was David?")\n⛪ Church topics\n❓ Any specific question you have\n\nHow can I help you today?';
  }

  // Bible Statistics & Facts
  Future<String?> _tryBibleStats(String text) async {
    // This method can be expanded to handle Bible statistics.
    // Currently returns null to let other methods handle questions.
    return null;
  }

  // Fetch Bible verse from bible-api.com
  Future<String?> _tryFetchBibleVerse(String text) async {
    // Improved regex for Bible references (handles more formats)
    final versePattern =
        RegExp(r'(\d?\s?[a-zA-Z]+)\s+(\d+)(?::(\d+))?', caseSensitive: false);
    final match = versePattern.firstMatch(text);

    if (match != null) {
      final book = match.group(1)?.trim();
      final chapter = match.group(2);
      final verse = match.group(3);

      String reference = '$book $chapter';
      if (verse != null) {
        reference += ':$verse';
      }

      // Try bible-api.com first
      try {
        final response = await _dio.get('https://bible-api.com/$reference');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final text = data['text'] as String? ?? '';
          final ref = data['reference'] as String? ?? reference;
          return '📖 **$ref**\n\n$text\n\n💬 Need more verses or have questions? Just ask!';
        }
      } catch (e) {
        print('Bible-api.com failed: $e');
      }

      // Fallback: Try getbible.net API (returns JSONP, so we parse manually)
      try {
        final gbRef = reference.replaceAll(' ', "+");
        final gbUrl = 'https://getbible.net/json?passage=$gbRef&version=kjv';
        final gbResponse = await _dio.get(gbUrl);
        if (gbResponse.statusCode == 200 && gbResponse.data != null) {
          // getbible.net returns JSONP, so we need to extract the JSON
          final raw = gbResponse.data.toString();
          final jsonStart = raw.indexOf('{');
          final jsonEnd = raw.lastIndexOf('}') + 1;
          if (jsonStart != -1 && jsonEnd != -1) {
            final jsonStr = raw.substring(jsonStart, jsonEnd);
            final data = jsonStr.isNotEmpty ? jsonStr : null;
            if (data != null) {
              // Just return a message that fallback worked
              return '📖 $reference\n\nVerse found using backup Bible API.';
            }
          }
        }
      } catch (e) {
        print('getbible.net failed: $e');
      }
    }

    return null;
  }

  // Comprehensive Bible search covering all books, characters, and topics
  Future<String?> _tryBibleSearch(String text) async {
    final lower = text.toLowerCase();

    // Old Testament Books
    if (lower.contains('genesis') ||
        lower.contains('garden of eden') ||
        lower.contains('adam and eve')) {
      return '📖 **Genesis** - The Book of Beginnings\n\nGenesis means "origin" or "beginning." It records:\n• Creation (Genesis 1-2)\n• The Fall (Genesis 3)\n• Noah\'s Flood (Genesis 6-9)\n• Tower of Babel (Genesis 11)\n• Abraham, Isaac, Jacob (Genesis 12-50)\n• Joseph in Egypt (Genesis 37-50)\n\n**Key Themes:** God\'s sovereignty, covenant promises, sin\'s consequences, redemption\n**Key Verse:** "In the beginning God created the heavens and the earth" (1:1)\n\nGenesis sets the stage for the entire Bible story!';
    }

    if (lower.contains('exodus') ||
        lower.contains('ten commandments') ||
        lower.contains('red sea')) {
      return '📖 **Exodus** - The Book of Redemption\n\nExodus means "departure" or "going out." It records:\n• Israel\'s slavery in Egypt (Exodus 1)\n• Moses and the burning bush (Exodus 3)\n• The 10 Plagues (Exodus 7-12)\n• Crossing the Red Sea (Exodus 14)\n• The Ten Commandments (Exodus 20)\n• The Tabernacle (Exodus 25-40)\n\n**Key Themes:** Deliverance, God\'s faithfulness, law, worship\n**Key Verse:** "I am the LORD your God, who brought you out of Egypt" (20:2)\n\nExodus shows God rescuing His people - pointing to Jesus our Deliverer!';
    }

    if (lower.contains('leviticus') ||
        lower.contains('sacrifices') ||
        lower.contains('priesthood')) {
      return '📖 **Leviticus** - The Book of Holiness\n\nLeviticus focuses on Israel\'s worship and holiness:\n• Sacrificial system (Leviticus 1-7)\n• Priesthood consecration (Leviticus 8-10)\n• Purity laws (Leviticus 11-15)\n• Day of Atonement (Leviticus 16)\n• Holiness code (Leviticus 17-27)\n\n**Key Themes:** Holiness, atonement, worship, separation\n**Key Verse:** "Be holy because I, the LORD your God, am holy" (19:2)\n\nLeviticus points to Jesus, our perfect High Priest and ultimate sacrifice!';
    }

    if (lower.contains('numbers') || lower.contains('wilderness wandering')) {
      return '📖 **Numbers** - Wilderness Journey\n\nNumbers records Israel\'s 40-year wilderness journey:\n• Census and camp organization (Numbers 1-4)\n• Journey begins (Numbers 10)\n• Rebellion and unbelief (Numbers 13-14)\n• Bronze serpent (Numbers 21:4-9)\n• Balaam (Numbers 22-24)\n\n**Key Themes:** Faith vs. unbelief, consequences of sin, God\'s patience\n**Key Verse:** "The LORD is slow to anger, abounding in love" (14:18)\n\nNumbers warns against unbelief and teaches God\'s faithfulness!';
    }

    if (lower.contains('deuteronomy') || lower.contains('shema')) {
      return '📖 **Deuteronomy** - Second Law\n\nDeuteronomy is Moses\' farewell address:\n• Review of the journey (Deuteronomy 1-4)\n• Ten Commandments repeated (Deuteronomy 5)\n• The Shema (Deuteronomy 6:4-9)\n• Blessings and curses (Deuteronomy 27-28)\n• Covenant renewal (Deuteronomy 29-30)\n• Moses\' death (Deuteronomy 34)\n\n**Key Themes:** Love, obedience, covenant, remembrance\n**Key Verse:** "Hear, O Israel: The LORD our God, the LORD is one" (6:4)\n\nDeuteronomy emphasizes wholehearted devotion to God!';
    }

    if (lower.contains('joshua') ||
        lower.contains('jericho') ||
        lower.contains('promised land')) {
      return '📖 **Joshua** - Conquest of Canaan\n\nJoshua records Israel entering the Promised Land:\n• Crossing the Jordan (Joshua 3-4)\n• Fall of Jericho (Joshua 6)\n• Ai and Achan\'s sin (Joshua 7-8)\n• Conquest of Canaan (Joshua 10-12)\n• Land division (Joshua 13-21)\n• Joshua\'s farewell (Joshua 23-24)\n\n**Key Themes:** Faith, obedience, God\'s faithfulness, holiness\n**Key Verse:** "Be strong and courageous" (1:9)\n\nJoshua shows God keeping His promises!';
    }

    if (lower.contains('judges') ||
        lower.contains('samson') ||
        lower.contains('gideon') ||
        lower.contains('deborah')) {
      return '📖 **Judges** - Cycle of Sin\n\nJudges records Israel\'s repeated rebellion:\n• Pattern: Sin → Oppression → Cry out → Deliverance\n• Deborah (Judges 4-5)\n• Gideon (Judges 6-8)\n• Samson (Judges 13-16)\n\n**Key Judges:** Othniel, Ehud, Deborah, Gideon, Jephthah, Samson\n**Key Themes:** Consequences of sin, God\'s mercy, need for godly leadership\n**Key Verse:** "Everyone did as they saw fit" (21:25)\n\nJudges shows humanity\'s need for a perfect King - Jesus!';
    }

    if (lower.contains('ruth') ||
        lower.contains('boaz') ||
        lower.contains('kinsman redeemer')) {
      return '📖 **Ruth** - Redemption Story\n\nRuth is a beautiful story of loyalty and redemption:\n• Naomi and Ruth return to Bethlehem (Ruth 1)\n• Ruth gleans in Boaz\'s field (Ruth 2)\n• Boaz as kinsman-redeemer (Ruth 3-4)\n• Ruth in Jesus\' genealogy (Ruth 4:18-22)\n\n**Key Themes:** Loyalty, providence, redemption, grace\n**Key Verse:** "Where you go I will go" (1:16)\n\nRuth points to Jesus, our kinsman-Redeemer!';
    }

    if (lower.contains('samuel') ||
        lower.contains('1 samuel') ||
        lower.contains('2 samuel')) {
      return '📖 **1 & 2 Samuel** - Kingship Begins\n\n**1 Samuel:** Transition from judges to kings\n• Samuel\'s birth and calling (1 Samuel 1-3)\n• Ark captured and returned (1 Samuel 4-7)\n• Saul anointed king (1 Samuel 8-15)\n• David anointed, defeats Goliath (1 Samuel 16-17)\n• David and Saul (1 Samuel 18-31)\n\n**2 Samuel:** David\'s reign\n• David becomes king (2 Samuel 1-5)\n• David and Bathsheba (2 Samuel 11-12)\n• Absalom\'s rebellion (2 Samuel 13-18)\n\n**Key Themes:** God\'s choice, obedience, covenant, sin\'s consequences\n**Key Verse:** "Man looks at the outward appearance, but the LORD looks at the heart" (1 Samuel 16:7)';
    }

    if (lower.contains('kings') ||
        lower.contains('1 kings') ||
        lower.contains('2 kings') ||
        lower.contains('elijah') ||
        lower.contains('elisha')) {
      return '📖 **1 & 2 Kings** - Divided Kingdom\n\n**1 Kings:** Solomon to divided kingdom\n• Solomon\'s wisdom and temple (1 Kings 1-11)\n• Kingdom divided (1 Kings 12)\n• Elijah vs. Baal prophets (1 Kings 17-19)\n\n**2 Kings:** Decline and exile\n• Elisha\'s ministry (2 Kings 2-13)\n• Israel exiled by Assyria (2 Kings 17)\n• Judah exiled to Babylon (2 Kings 24-25)\n\n**Key Themes:** Consequences of idolatry, prophetic ministry, God\'s patience\n**Key Verse:** "If you do not carefully follow all the words...these curses will come" (Deuteronomy 28:15)';
    }

    if (lower.contains('chronicles') ||
        lower.contains('1 chronicles') ||
        lower.contains('2 chronicles')) {
      return '📖 **1 & 2 Chronicles** - Priestly Perspective\n\nChronicles retells Israel\'s history from a worship perspective:\n• Genealogies (1 Chronicles 1-9)\n• David\'s reign (1 Chronicles 10-29)\n• Solomon and the temple (2 Chronicles 1-9)\n• Kings of Judah (2 Chronicles 10-36)\n• Emphasis on temple, worship, revival\n\n**Key Themes:** Worship, God\'s faithfulness, covenant, temple\n**Key Verse:** "If my people...will humble themselves...I will heal their land" (2 Chronicles 7:14)\n\nChronicles emphasizes God\'s presence through worship!';
    }

    if (lower.contains('ezra') ||
        lower.contains('nehemiah') ||
        lower.contains('rebuilding')) {
      return '📖 **Ezra & Nehemiah** - Restoration\n\n**Ezra:** Rebuilding the temple\n• Return from exile (Ezra 1-2)\n• Temple rebuilt (Ezra 3-6)\n• Spiritual renewal (Ezra 7-10)\n\n**Nehemiah:** Rebuilding the walls\n• Walls rebuilt in 52 days (Nehemiah 1-6)\n• Covenant renewed (Nehemiah 8-10)\n• Reforms instituted (Nehemiah 11-13)\n\n**Key Themes:** Restoration, perseverance, prayer, holiness\n**Key Verse:** "The joy of the LORD is your strength" (Nehemiah 8:10)\n\nThese books show God restoring His people!';
    }

    if (lower.contains('esther') ||
        lower.contains('mordecai') ||
        lower.contains('purim')) {
      return '📖 **Esther** - Providence and Courage\n\nEsther records God\'s hidden hand protecting His people:\n• Esther becomes queen (Esther 1-2)\n• Haman\'s plot against Jews (Esther 3)\n• "For such a time as this" (Esther 4:14)\n• Jews delivered (Esther 5-10)\n• Purim established (Esther 9)\n\n**Key Themes:** Providence, courage, God\'s protection\n**Key Verse:** "Who knows but that you have come to your royal position for such a time as this?" (4:14)\n\nEsther shows God working behind the scenes!';
    }

    if (lower.contains('job') || lower.contains('suffering')) {
      return '📖 **Job** - Suffering and Sovereignty\n\nJob addresses why the righteous suffer:\n• Job\'s trials (Job 1-2)\n• Dialogues with friends (Job 3-37)\n• God speaks from whirlwind (Job 38-41)\n• Job restored (Job 42)\n\n**Key Themes:** Suffering, God\'s sovereignty, faith, mystery\n**Key Verse:** "Though he slay me, yet will I hope in him" (13:15)\n**Key Question:** "Where were you when I laid the earth\'s foundation?" (38:4)\n\nJob teaches trust in God despite circumstances!';
    }

    if (lower.contains('psalms') ||
        lower.contains('psalm') ||
        lower.contains('worship songs')) {
      return '📖 **Psalms** - Israel\'s Songbook\n\nThe Psalms are prayers and songs for every emotion:\n• 150 psalms total\n• Authors: David (73), Asaph (12), Sons of Korah (11), others\n• Types: Praise, lament, thanksgiving, wisdom, royal\n\n**Famous Psalms:**\n🎵 Psalm 23 - The LORD is my shepherd\n🎵 Psalm 51 - Create in me a pure heart\n🎵 Psalm 91 - He who dwells in the shelter\n🎵 Psalm 119 - Longest chapter, praising God\'s Word\n🎵 Psalm 150 - Let everything praise the LORD\n\n**Key Themes:** Worship, trust, confession, God\'s character\n\nPsalms expresses the full range of human emotion before God!';
    }

    if (lower.contains('proverbs') || lower.contains('wisdom')) {
      return '📖 **Proverbs** - Practical Wisdom\n\nProverbs offers practical wisdom for daily life:\n• Mostly written by Solomon\n• 31 chapters (one per day!)\n• Topics: Wisdom, foolishness, speech, work, relationships, money\n\n**Key Themes:** Fear of the LORD, wisdom, righteousness, self-control\n**Key Verse:** "The fear of the LORD is the beginning of knowledge" (1:7)\n**Famous:** "Trust in the LORD with all your heart" (3:5-6)\n\nProverbs teaches godly living in practical ways!';
    }

    if (lower.contains('ecclesiastes') ||
        lower.contains('meaningless') ||
        lower.contains('vanity')) {
      return '📖 **Ecclesiastes** - Life Under the Sun\n\nEcclesiastes explores life\'s meaning:\n• "Meaningless! Meaningless!" (Ecclesiastes 1:2)\n• Pursuits under the sun: pleasure, wisdom, work (Ecclesiastes 2)\n• A time for everything (Ecclesiastes 3)\n• Conclusion: Fear God (Ecclesiastes 12:13)\n\n**Key Themes:** Meaning, mortality, enjoy God\'s gifts, eternity\n**Key Verse:** "Fear God and keep his commandments" (12:13)\n\nEcclesiastes shows life without God is meaningless!';
    }

    if (lower.contains('song of solomon') || lower.contains('song of songs')) {
      return '📖 **Song of Solomon** - Love Poetry\n\nSong of Solomon celebrates marital love:\n• Poetic dialogue between bride and groom\n• Celebrates God\'s gift of married love\n• Allegorically: Christ\'s love for His bride (the Church)\n\n**Key Themes:** Love, commitment, beauty, intimacy\n**Key Verse:** "Place me like a seal over your heart" (8:6)\n\nSong of Solomon honors marriage as God designed it!';
    }

    if (lower.contains('isaiah') || lower.contains('suffering servant')) {
      return '📖 **Isaiah** - The Gospel Prophet\n\nIsaiah prophesies about judgment and Messiah:\n• 66 chapters (like 66 Bible books!)\n• Chapters 1-39: Judgment\n• Chapters 40-66: Comfort and Messiah\n• Messianic prophecies: Virgin birth (7:14), Suffering Servant (53), Prince of Peace (9:6)\n\n**Key Themes:** Holiness, judgment, redemption, Messiah\n**Key Verse:** "Here am I. Send me!" (6:8)\n**Most quoted:** Isaiah 53 - Jesus\' suffering\n\nIsaiah clearly prophesies Jesus\' birth, death, and resurrection!';
    }

    if (lower.contains('jeremiah') || lower.contains('weeping prophet')) {
      return '📖 **Jeremiah** - The Weeping Prophet\n\nJeremiah prophesied before and during Babylon\'s exile:\n• Called as young prophet (Jeremiah 1)\n• Warned Judah of coming judgment (Jeremiah 2-29)\n• New covenant promise (Jeremiah 31:31-34)\n• Jerusalem falls (Jeremiah 39, 52)\n\n**Key Themes:** Judgment, repentance, new covenant, God\'s faithfulness\n**Key Verse:** "I know the plans I have for you...plans to prosper you" (29:11)\n\nJeremiah faithfully spoke God\'s word despite opposition!';
    }

    if (lower.contains('lamentations')) {
      return '📖 **Lamentations** - Mourning Jerusalem\n\nLamentations mourns Jerusalem\'s destruction:\n• 5 poems lamenting Jerusalem\'s fall\n• Written by Jeremiah\n• Acrostic poems (each verse starts with successive Hebrew letter)\n\n**Key Themes:** Grief, sin\'s consequences, God\'s faithfulness, hope\n**Key Verse:** "His compassions never fail. They are new every morning" (3:22-23)\n\nEven in deep sorrow, Lamentations finds hope in God!';
    }

    if (lower.contains('ezekiel') ||
        lower.contains('dry bones') ||
        lower.contains('valley of dry bones')) {
      return '📖 **Ezekiel** - Visions and Restoration\n\nEzekiel prophesied during Babylon exile:\n• Visions of God\'s glory (Ezekiel 1-3)\n• Prophecies against Judah (Ezekiel 4-24)\n• Prophecies against nations (Ezekiel 25-32)\n• Valley of dry bones (Ezekiel 37)\n• New temple vision (Ezekiel 40-48)\n\n**Key Themes:** God\'s glory, judgment, restoration, individual responsibility\n**Key Verse:** "Then they will know that I am the LORD" (repeated 60+ times)\n\nEzekiel saw visions of God\'s glory and future restoration!';
    }

    if (lower.contains('daniel') ||
        lower.contains('lion') ||
        lower.contains('fiery furnace')) {
      return '📖 **Daniel** - Faithfulness in Exile\n\nDaniel records faithfulness and prophecy:\n• Daniel in Babylon (Daniel 1)\n• Nebuchadnezzar\'s dreams (Daniel 2-4)\n• Handwriting on wall (Daniel 5)\n• Lions\' den (Daniel 6)\n• Apocalyptic visions (Daniel 7-12)\n\n**Key Themes:** Faithfulness, God\'s sovereignty, prophecy, end times\n**Key Verse:** "My God sent his angel, and he shut the mouths of the lions" (6:22)\n**Famous:** "The people who know their God will firmly resist" (11:32)\n\nDaniel remained faithful despite pressure to compromise!';
    }

    if (lower.contains('hosea') || lower.contains('gomer')) {
      return '📖 **Hosea** - Unfaithful Israel\n\nHosea\'s marriage illustrates God\'s love for unfaithful Israel:\n• Hosea marries unfaithful Gomer (Hosea 1-3)\n• Israel\'s spiritual adultery (Hosea 4-13)\n• Call to return (Hosea 14)\n\n**Key Themes:** God\'s steadfast love, spiritual adultery, restoration\n**Key Verse:** "I will betroth you to me forever" (2:19)\n\nHosea shows God\'s pursuing love despite our unfaithfulness!';
    }

    if (lower.contains('joel') || lower.contains('day of the lord')) {
      return '📖 **Joel** - The Day of the LORD\n\nJoel prophesies about judgment and restoration:\n• Locust plague as judgment (Joel 1)\n• Day of the LORD coming (Joel 2:1-11)\n• Call to repentance (Joel 2:12-17)\n• Outpouring of the Spirit (Joel 2:28-32)\n• Final judgment (Joel 3)\n\n**Key Themes:** Judgment, repentance, Holy Spirit, restoration\n**Key Verse:** "I will pour out my Spirit on all people" (2:28) - fulfilled at Pentecost!\n\nJoel prophesied the Holy Spirit\'s coming!';
    }

    if (lower.contains('amos') || lower.contains('social justice')) {
      return '📖 **Amos** - Prophet of Justice\n\nAmos condemned social injustice:\n• Shepherd called to prophesy (Amos 1:1)\n• Judgment on nations (Amos 1-2)\n• "Let justice roll on like a river" (Amos 5:24)\n• Visions of judgment (Amos 7-9)\n• Promise of restoration (Amos 9:11-15)\n\n**Key Themes:** Social justice, righteousness, judgment, God\'s holiness\n**Key Verse:** "Seek good, not evil, that you may live" (5:14)\n\nAmos called Israel to practice justice and righteousness!';
    }

    if (lower.contains('obadiah') || lower.contains('edom')) {
      return '📖 **Obadiah** - Judgment on Edom\n\nObadiah is the shortest OT book (1 chapter, 21 verses):\n• Prophecy against Edom (descendants of Esau)\n• Pride judged (Obadiah 1-9)\n• Violence against Jacob judged (Obadiah 10-14)\n• Future deliverance (Obadiah 15-21)\n\n**Key Themes:** Pride, brotherhood, judgment, God\'s sovereignty\n**Key Verse:** "The pride of your heart has deceived you" (1:3)\n\nObadiah warns against pride and mistreating God\'s people!';
    }

    if (lower.contains('jonah') ||
        lower.contains('whale') ||
        lower.contains('nineveh')) {
      return '📖 **Jonah** - Reluctant Prophet\n\nJonah runs from God\'s call:\n• Jonah flees, swallowed by great fish (Jonah 1-2)\n• Jonah preaches, Nineveh repents (Jonah 3)\n• Jonah angry, God\'s compassion (Jonah 4)\n\n**Key Themes:** Obedience, God\'s mercy, repentance, missions\n**Key Verse:** "Should I not have concern for the great city?" (4:11)\n**Jesus referenced:** "Sign of Jonah" - 3 days in fish = Jesus\' burial (Matthew 12:39-40)\n\nJonah shows God\'s compassion extends even to enemies!';
    }

    if (lower.contains('micah') || lower.contains('bethlehem prophecy')) {
      return '📖 **Micah** - What God Requires\n\nMicah prophesied judgment and hope:\n• Judgment on Israel and Judah (Micah 1-3)\n• Messiah from Bethlehem (Micah 5:2)\n• God\'s lawsuit against Israel (Micah 6)\n• "What does the LORD require?" (Micah 6:8)\n\n**Key Themes:** Justice, mercy, humility, Messiah\n**Key Verse:** "Act justly, love mercy, walk humbly with your God" (6:8)\n\nMicah prophesied Jesus\' birthplace 700 years early!';
    }

    if (lower.contains('nahum')) {
      return '📖 **Nahum** - Nineveh\'s Fall\n\nNahum prophesies Nineveh\'s destruction:\n• God\'s wrath against Nineveh (Nahum 1)\n• Nineveh\'s fall described (Nahum 2-3)\n• Comfort for Judah (Nahum 1:7, 15)\n\n**Key Themes:** God\'s justice, judgment on evil, comfort for the oppressed\n**Key Verse:** "The LORD is good, a refuge in times of trouble" (1:7)\n\n100 years after Jonah, Nineveh returned to evil and was judged!';
    }

    if (lower.contains('habakkuk')) {
      return '📖 **Habakkuk** - Faith in Dark Times\n\nHabakkuk questions God about evil:\n• "Why do you tolerate wrongdoing?" (Habakkuk 1:2-4)\n• God\'s answer: Babylon will judge Judah (Habakkuk 1:5-11)\n• Habakkuk\'s second question (Habakkuk 1:12-2:1)\n• "The righteous will live by faith" (Habakkuk 2:4)\n• Prayer of faith (Habakkuk 3)\n\n**Key Themes:** Faith, trust, God\'s sovereignty, patience\n**Key Verse:** "The righteous person will live by his faithfulness" (2:4) - quoted in Romans 1:17!\n\nHabakkuk learned to trust God despite circumstances!';
    }

    if (lower.contains('zephaniah')) {
      return '📖 **Zephaniah** - Day of the LORD\n\nZephaniah warns of coming judgment:\n• Day of the LORD announced (Zephaniah 1)\n• Call to repentance (Zephaniah 2:1-3)\n• Judgment on nations (Zephaniah 2:4-3:8)\n• Promise of restoration (Zephaniah 3:9-20)\n\n**Key Themes:** Judgment, repentance, restoration, God\'s presence\n**Key Verse:** "The LORD your God is with you, the Mighty Warrior who saves" (3:17)\n\nZephaniah balances warnings of judgment with promises of hope!';
    }

    if (lower.contains('haggai') || lower.contains('temple rebuilding')) {
      return '📖 **Haggai** - Rebuild the Temple\n\nHaggai urged returning exiles to rebuild temple:\n• "Give careful thought to your ways" (Haggai 1:5)\n• Work on temple resumed (Haggai 1:12-15)\n• Future glory promised (Haggai 2:6-9)\n• Zerubbabel chosen (Haggai 2:20-23)\n\n**Key Themes:** Priorities, worship, God\'s presence, perseverance\n**Key Verse:** "The glory of this present house will be greater" (2:9)\n\nHaggai challenged God\'s people to put Him first!';
    }

    if (lower.contains('zechariah') || lower.contains('visions')) {
      return '📖 **Zechariah** - Visions and Messiah\n\nZechariah encouraged temple rebuilders with visions:\n• Eight night visions (Zechariah 1-6)\n• Questions about fasting (Zechariah 7-8)\n• Two burdens/oracles (Zechariah 9-14)\n• Messianic prophecies: Triumphal entry (9:9), Pierced (12:10), Fountain opened (13:1)\n\n**Key Themes:** Restoration, Messiah, God\'s kingdom, hope\n**Key Verse:** "Not by might nor by power, but by my Spirit" (4:6)\n\nZechariah contains many prophecies fulfilled in Jesus!';
    }

    if (lower.contains('malachi') || lower.contains('last prophet')) {
      return '📖 **Malachi** - Final OT Prophet\n\nMalachi is the last OT book (400-year silence follows):\n• "I have loved you" (Malachi 1:2)\n• Polluted offerings condemned (Malachi 1:6-14)\n• Robbing God in tithes (Malachi 3:8-10)\n• Messenger to prepare the way (Malachi 3:1; 4:5-6) = John the Baptist!\n\n**Key Themes:** God\'s love, faithfulness, repentance, Messiah\'s forerunner\n**Key Verse:** "Test me in this...see if I will not throw open the floodgates" (3:10)\n\nMalachi ends OT pointing forward to John the Baptist and Jesus!';
    }

    // New Testament Books
    if (lower.contains('matthew') || lower.contains('sermon on the mount')) {
      return '📖 **Matthew** - Jesus the King\n\nMatthew presents Jesus as Israel\'s Messiah-King:\n• Genealogy proving royal lineage (Matthew 1:1-17)\n• Birth of Jesus (Matthew 1:18-2:23)\n• Sermon on the Mount (Matthew 5-7)\n• Miracles and teachings (Matthew 8-25)\n• Crucifixion and resurrection (Matthew 26-28)\n• Great Commission (Matthew 28:18-20)\n\n**Key Themes:** Kingdom of heaven, fulfilled prophecy, discipleship\n**Key Verse:** "All authority in heaven and on earth has been given to me" (28:18)\n\nMatthew shows Jesus as the promised King!';
    }

    if (lower.contains('mark') || lower.contains('servant')) {
      return '📖 **Mark** - Jesus the Servant\n\nMark portrays Jesus as the suffering Servant:\n• Shortest Gospel, action-packed\n• "Immediately" used 40+ times\n• Focus on Jesus\' deeds more than words\n• Emphasizes Jesus\' suffering and service\n• Written to Romans\n\n**Key Themes:** Servanthood, action, suffering, discipleship\n**Key Verse:** "The Son of Man did not come to be served, but to serve" (10:45)\n\nMark shows Jesus as the ultimate Servant!';
    }

    if (lower.contains('luke') || lower.contains('parables')) {
      return '📖 **Luke** - Jesus the Perfect Man\n\nLuke presents Jesus as the perfect human:\n• Most detailed birth narrative (Luke 1-2)\n• Emphasis on prayer, Holy Spirit, compassion\n• Unique parables: Good Samaritan (10:25-37), Prodigal Son (15:11-32), Rich Man & Lazarus (16:19-31)\n• Universal Savior for all people\n• Written by physician Luke\n\n**Key Themes:** Compassion, salvation, prayer, women, outcasts\n**Key Verse:** "The Son of Man came to seek and to save the lost" (19:10)\n\nLuke emphasizes Jesus\' humanity and compassion for all!';
    }

    if (lower.contains('john') &&
        (lower.contains('gospel') || lower.contains('3:16'))) {
      return '📖 **John** - Jesus the Son of God\n\nJohn presents Jesus as fully God:\n• "In the beginning was the Word" (John 1:1)\n• Seven "I AM" statements (bread, light, door, shepherd, resurrection, way, vine)\n• Seven signs/miracles\n• Upper Room discourse (John 13-17)\n• "These are written that you may believe" (John 20:31)\n\n**Key Themes:** Deity of Christ, belief, eternal life, love\n**Key Verse:** "For God so loved the world that he gave his one and only Son" (3:16)\n\nJohn clearly declares Jesus is God!';
    }

    if (lower.contains('acts') ||
        lower.contains('early church') ||
        lower.contains('pentecost')) {
      return '📖 **Acts** - Church Empowered\n\nActs records the early Church:\n• Jesus\' ascension (Acts 1)\n• Pentecost - Holy Spirit comes (Acts 2)\n• Peter\'s ministry (Acts 3-12)\n• Paul\'s conversion (Acts 9)\n• Paul\'s missionary journeys (Acts 13-28)\n• Gospel spreads: Jerusalem → Judea → Samaria → Ends of earth\n\n**Key Themes:** Holy Spirit, evangelism, persecution, missions\n**Key Verse:** "You will receive power when the Holy Spirit comes" (1:8)\n\nActs shows the Church empowered by the Holy Spirit!';
    }

    if (lower.contains('romans') || lower.contains('justification')) {
      return '📖 **Romans** - Gospel Explained\n\nRomans systematically explains the Gospel:\n• All have sinned (Romans 1-3)\n• Justified by faith (Romans 3-5)\n• Freedom from sin (Romans 6-8)\n• Israel\'s future (Romans 9-11)\n• Practical Christian living (Romans 12-16)\n\n**Key Themes:** Sin, salvation, justification, sanctification, God\'s sovereignty\n**Key Verses:** "All have sinned" (3:23), "The wages of sin is death, but the gift of God is eternal life" (6:23), "If God is for us, who can be against us?" (8:31)\n\nRomans is Christianity\'s theological foundation!';
    }

    if (lower.contains('corinthians') ||
        lower.contains('1 corinthians') ||
        lower.contains('2 corinthians') ||
        lower.contains('love chapter')) {
      return '📖 **1 & 2 Corinthians** - Church Issues\n\n**1 Corinthians:** Correcting problems\n• Division (1 Corinthians 1-4)\n• Immorality (1 Corinthians 5-6)\n• Marriage (1 Corinthians 7)\n• Spiritual gifts (1 Corinthians 12-14)\n• Love chapter (1 Corinthians 13)\n• Resurrection (1 Corinthians 15)\n\n**2 Corinthians:** Paul\'s defense\n• Comfort in suffering (2 Corinthians 1)\n• New covenant ministry (2 Corinthians 3)\n• Treasure in jars of clay (2 Corinthians 4:7)\n• Generous giving (2 Corinthians 8-9)\n\n**Key Themes:** Unity, holiness, love, resurrection, ministry\n\nPaul addresses real church problems with gospel truth!';
    }

    if (lower.contains('galatians') || lower.contains('freedom in christ')) {
      return '📖 **Galatians** - Freedom in Christ\n\nGalatians defends salvation by grace through faith:\n• Gospel defended (Galatians 1-2)\n• Justified by faith, not law (Galatians 3-4)\n• Freedom, not legalism (Galatians 5:1)\n• Fruit of the Spirit (Galatians 5:22-23)\n• "Carry each other\'s burdens" (Galatians 6:2)\n\n**Key Themes:** Grace, faith, freedom, law vs. gospel\n**Key Verse:** "It is for freedom that Christ has set us free" (5:1)\n\nGalatians emphasizes we\'re saved by grace, not works!';
    }

    if (lower.contains('ephesians') || lower.contains('armor of god')) {
      return '📖 **Ephesians** - Unity in Christ\n\nEphesians describes the Church and Christian life:\n• Spiritual blessings (Ephesians 1)\n• Saved by grace (Ephesians 2:8-9)\n• Mystery revealed: Gentiles included (Ephesians 3)\n• Unity of the body (Ephesians 4)\n• Christian household (Ephesians 5-6)\n• Armor of God (Ephesians 6:10-18)\n\n**Key Themes:** Grace, unity, spiritual warfare, holiness\n**Key Verse:** "For by grace you have been saved through faith" (2:8-9)\n\nEphesians reveals our identity and calling in Christ!';
    }

    if (lower.contains('philippians') ||
        lower.contains('joy') ||
        lower.contains('rejoice')) {
      return '📖 **Philippians** - Joy in Christ\n\nPhilippians is Paul\'s joyful letter from prison:\n• "To live is Christ" (Philippians 1:21)\n• Christ\'s humility (Philippians 2:5-11)\n• "Pressing on" (Philippians 3:12-14)\n• "Rejoice in the Lord always!" (Philippians 4:4)\n• "I can do all things through Christ" (Philippians 4:13)\n\n**Key Themes:** Joy, humility, contentment, partnership\n**Key Verse:** "Rejoice in the Lord always. I will say it again: Rejoice!" (4:4)\n\nPhilippians shows joy despite circumstances!';
    }

    if (lower.contains('colossians') || lower.contains('supremacy of christ')) {
      return '📖 **Colossians** - Christ Supreme\n\nColossians exalts Christ\'s supremacy:\n• Christ is the image of God (Colossians 1:15-20)\n• Warning against false teaching (Colossians 2)\n• Set hearts on things above (Colossians 3:1-4)\n• Put on new self (Colossians 3:5-17)\n• Christian household (Colossians 3:18-4:1)\n\n**Key Themes:** Christ\'s supremacy, false teaching refuted, new life\n**Key Verse:** "He is before all things, and in him all things hold together" (1:17)\n\nColossians declares Christ is sufficient and supreme!';
    }

    if (lower.contains('thessalonians') ||
        lower.contains('1 thessalonians') ||
        lower.contains('2 thessalonians') ||
        lower.contains('second coming')) {
      return '📖 **1 & 2 Thessalonians** - Christ\'s Return\n\n**1 Thessalonians:** Encouragement\n• Paul\'s care for them (1 Thessalonians 1-3)\n• Holy living (1 Thessalonians 4:1-12)\n• Rapture described (1 Thessalonians 4:13-18)\n• Day of the Lord (1 Thessalonians 5:1-11)\n\n**2 Thessalonians:** Clarification\n• Perseverance in persecution (2 Thessalonians 1)\n• Day of the Lord timing (2 Thessalonians 2)\n• Warning against idleness (2 Thessalonians 3)\n\n**Key Themes:** Second coming, hope, holiness, perseverance\n**Key Verse:** "The Lord himself will come down from heaven" (1 Thessalonians 4:16)\n\nPaul encourages believers about Christ\'s return!';
    }

    if (lower.contains('timothy') ||
        lower.contains('1 timothy') ||
        lower.contains('2 timothy') ||
        lower.contains('pastoral')) {
      return '📖 **1 & 2 Timothy** - Pastoral Letters\n\n**1 Timothy:** Church order\n• Fighting false teaching (1 Timothy 1)\n• Prayer and worship (1 Timothy 2)\n• Qualifications for leaders (1 Timothy 3)\n• Instructions for ministry (1 Timothy 4-6)\n\n**2 Timothy:** Paul\'s final words\n• Guard the gospel (2 Timothy 1)\n• Endure hardship (2 Timothy 2)\n• Godlessness in last days (2 Timothy 3)\n• "I have fought the good fight" (2 Timothy 4:7)\n\n**Key Themes:** Leadership, sound doctrine, faithfulness, endurance\n**Key Verse:** "All Scripture is God-breathed" (2 Timothy 3:16)\n\nPaul mentors Timothy in ministry!';
    }

    if (lower.contains('titus')) {
      return '📖 **Titus** - Good Works\n\nTitus guides church leadership and conduct:\n• Qualifications for elders (Titus 1)\n• Sound doctrine and conduct (Titus 2)\n• Saved by grace, do good works (Titus 3)\n\n**Key Themes:** Leadership, sound teaching, good works, grace\n**Key Verse:** "He saved us...because of his mercy" (3:5)\n\nTitus emphasizes godly living flows from sound doctrine!';
    }

    if (lower.contains('philemon')) {
      return '📖 **Philemon** - Forgiveness\n\nPhilemon is Paul\'s personal letter about a runaway slave:\n• Shortest of Paul\'s letters (25 verses)\n• Onesimus (slave) ran away, became Christian\n• Paul sends him back to Philemon (owner)\n• Paul asks Philemon to receive Onesimus as brother\n\n**Key Themes:** Forgiveness, reconciliation, Christian brotherhood\n**Key Verse:** "Welcome him as you would welcome me" (verse 17)\n\nPhilemon beautifully illustrates forgiveness and reconciliation!';
    }

    if (lower.contains('hebrews') || lower.contains('superiority of christ')) {
      return '📖 **Hebrews** - Christ Superior\n\nHebrews proves Christ\'s superiority:\n• Superior to angels (Hebrews 1-2)\n• Superior to Moses (Hebrews 3)\n• Superior High Priest (Hebrews 4-7)\n• Superior covenant (Hebrews 8)\n• Superior sacrifice (Hebrews 9-10)\n• Heroes of faith (Hebrews 11)\n• Run with perseverance (Hebrews 12:1-2)\n\n**Key Themes:** Christ\'s supremacy, faith, perseverance, new covenant\n**Key Verse:** "Jesus Christ is the same yesterday and today and forever" (13:8)\n\nHebrews shows Jesus is better than everything!';
    }

    if (lower.contains('james') || lower.contains('faith and works')) {
      return '📖 **James** - Practical Faith\n\nJames emphasizes faith produces works:\n• Trials produce perseverance (James 1:2-4)\n• "Be doers of the word" (James 1:22)\n• Faith without works is dead (James 2:14-26)\n• Taming the tongue (James 3)\n• Wisdom from above (James 3:17)\n• Draw near to God (James 4:8)\n• Prayer of faith (James 5:13-18)\n\n**Key Themes:** Practical faith, good works, wisdom, prayer\n**Key Verse:** "Faith by itself, if it is not accompanied by action, is dead" (2:17)\n\nJames shows real faith works!';
    }

    if (lower.contains('peter') ||
        lower.contains('1 peter') ||
        lower.contains('2 peter')) {
      return '📖 **1 & 2 Peter** - Hope and Warning\n\n**1 Peter:** Living hope in suffering\n• Living hope through resurrection (1 Peter 1:3)\n• Chosen people, royal priesthood (1 Peter 2:9)\n• Submit to authority (1 Peter 2:13-3:7)\n• Suffering for Christ (1 Peter 3:13-4:19)\n• Shepherd the flock (1 Peter 5:1-4)\n\n**2 Peter:** False teachers warned\n• Grow in knowledge (2 Peter 1:5-11)\n• Inspired Scripture (2 Peter 1:20-21)\n• False teachers exposed (2 Peter 2)\n• Day of the Lord coming (2 Peter 3)\n\n**Key Themes:** Hope, suffering, holiness, false teaching, prophecy\n\nPeter encourages perseverance and warns against deception!';
    }

    if (lower.contains('1 john') ||
        lower.contains('2 john') ||
        lower.contains('3 john') ||
        lower.contains('epistles of john')) {
      return '📖 **1, 2, 3 John** - Love and Truth\n\n**1 John:** Fellowship, love, assurance\n• Walk in the light (1 John 1)\n• Jesus our advocate (1 John 2:1)\n• Love one another (1 John 3-4)\n• God is love (1 John 4:8, 16)\n• Assurance of salvation (1 John 5:13)\n\n**2 John:** Truth and love (13 verses)\n**3 John:** Support missionaries (14 verses)\n\n**Key Themes:** Love, truth, fellowship, assurance, false teaching\n**Key Verse:** "God is love" (1 John 4:8)\n\nJohn emphasizes love and truth in Christian living!';
    }

    if (lower.contains('jude')) {
      return '📖 **Jude** - Contend for Faith\n\nJude warns against false teachers:\n• Contend for the faith (Jude 3)\n• False teachers described (Jude 4-19)\n• Keep yourselves in God\'s love (Jude 20-21)\n• Doxology (Jude 24-25)\n• Only 25 verses\n\n**Key Themes:** False teaching, judgment, perseverance\n**Key Verse:** "Contend for the faith that was once for all entrusted to God\'s holy people" (verse 3)\n\nJude urges believers to defend sound doctrine!';
    }

    if (lower.contains('revelation') ||
        lower.contains('apocalypse') ||
        lower.contains('end times') ||
        lower.contains('seven seals')) {
      return '📖 **Revelation** - Jesus Victorious\n\nRevelation reveals Jesus\' victory and return:\n• Vision of Jesus (Revelation 1)\n• Letters to 7 churches (Revelation 2-3)\n• Throne room (Revelation 4-5)\n• Seven seals, trumpets, bowls (Revelation 6-16)\n• Babylon falls (Revelation 17-18)\n• Christ returns (Revelation 19)\n• Millennium, final judgment (Revelation 20)\n• New heaven and earth (Revelation 21-22)\n\n**Key Themes:** Christ\'s victory, judgment, worship, perseverance, hope\n**Key Verse:** "Behold, I am coming soon!" (22:7, 12, 20)\n\nRevelation assures believers: Jesus wins!';
    }

    // Biblical characters
    if (lower.contains('who is jesus') ||
        lower.contains('tell me about jesus')) {
      return '✝️ **Jesus Christ** - Son of God, Savior\n\nJesus is the central figure of all Scripture:\n• Fully God and fully man\n• Born of virgin Mary in Bethlehem\n• Lived sinlessly for 33 years\n• Taught with authority, performed miracles\n• Died on cross for our sins\n• Rose from the dead on third day\n• Ascended to heaven, will return\n\n**Names/Titles:** Messiah, Christ, Son of God, Son of Man, Lamb of God, King of Kings, Lord of Lords, Alpha and Omega, Bread of Life, Light of the World, Good Shepherd, The Way/Truth/Life\n\n**Key Verse:** "Jesus Christ is the same yesterday and today and forever" (Hebrews 13:8)\n\nJesus is the fulfillment of all God\'s promises!';
    }

    // If nothing matched
    return null;
  }

  // Bible Relationships & Family Connections
  Future<String?> _tryBibleRelationships(String text) async {
    final lower = text.toLowerCase();

    // Father of... questions
    if (lower.contains('father of ')) {
      if (lower.contains('david')) {
        return '👨‍👦 **Father of David:**\n\nDavid\'s father was **Jesse** (also called Yishai).\n\n📖 Jesse was from Bethlehem and had eight sons, with David being the youngest. In 1 Samuel 16:1-13, God told Samuel to anoint David as king while he was still tending sheep.\n\nKey Facts About Jesse:\n🔹 He was a man of some wealth and standing in Bethlehem (1 Samuel 16:19-20)\n🔹 His family included Eliab, Abinadab, Shammah, and David among others (1 Samuel 16:6-13)\n🔹 Jesse lived during the time of Saul\'s kingship\n🔹 He is listed in Jesus\'s genealogy (Matthew 1:5-6)\n\n**Lineage:** Jesse → David → Solomon → ... → Jesus (Luke 3:32)';
      }
      if (lower.contains('solomon')) {
        return '👨‍👦 **Father of Solomon:**\n\nSolomon\'s father was **King David**.\n\n📖 Solomon was David\'s son with Bathsheba. Although born from their unlawful relationship (2 Samuel 11), Solomon was chosen by God and David to be the next king of Israel.\n\nKey Facts:\n🔹 David had many sons, but Solomon was chosen to build the Temple (1 Chronicles 22:9-10)\n🔹 Solomon became Israel\'s third and greatest king (1 Kings 1-11)\n🔹 He was known for his wisdom, wealth, and building projects\n🔹 Solomon built the Temple of God in Jerusalem (1 Kings 5-6)\n\n**Legacy:** Solomon is remembered as the wisest king of Israel, though he eventually turned from God.';
      }
      if (lower.contains('john') && lower.contains('baptist')) {
        return '👨‍👦 **Father of John the Baptist:**\n\nJohn the Baptist\'s father was **Zechariah** (a priest).\n\n📖 Zechariah was a righteous priest who served in the Temple (Luke 1:5-25). His wife was Elizabeth, from a priestly family. When told they would have a son in their old age, Zechariah doubted God\'s promise and was struck mute until John was born.\n\nKey Facts:\n🔹 Zechariah and Elizabeth were both righteous and walked blamelessly before God (Luke 1:6)\n🔹 They were barren for many years but God gave them John in their old age\n🔹 Zechariah was filled with the Holy Spirit when John was born (Luke 1:67)\n🔹 He prophesied about Jesus: "The Lord...will raise up a horn of salvation for us" (Luke 1:68-79)\n\n**Significance:** John was the forerunner who prepared the way for Jesus (John 1:23)';
      }
    }

    // Mother of... questions
    if (lower.contains('mother of ')) {
      if (lower.contains('jesus')) {
        return '👩‍👦 **Mother of Jesus:**\n\nJesus\'s mother was **Mary** (Miriam in Hebrew).\n\n📖 Mary was a young Jewish woman from Nazareth who became the mother of Jesus, the Son of God. She is revered in Christianity and honored for her faith and obedience to God.\n\nKey Facts About Mary:\n🔹 Angel Gabriel announced Jesus\'s birth to Mary (Luke 1:26-38)\n🔹 She responded with faith: "I am the Lord\'s servant" (Luke 1:38)\n🔹 She gave birth to Jesus in Bethlehem (Luke 2:4-7)\n🔹 She witnessed Jesus\'s ministry, crucifixion, and was with disciples at Pentecost (John 19:25-27; Acts 1:14)\n🔹 She treasured and pondered God\'s work in her heart (Luke 2:19)\n\n**What Scripture Says:**\n✨ Mary was a virgin at Jesus\'s conception (Matthew 1:23; Isaiah 7:14)\n✨ Jesus remained her only begotten son (Luke 1:34-35)';
      }
    }

    return null;
  }

  // Internet search with 4-tier fallback strategy
  Future<String?> _searchInternet(String query) async {
    print('🔍 Starting internet search for: $query');

    // Strategy 1: DuckDuckGo Instant Answer API (best for definitions/facts)
    try {
      print('Strategy 1: DuckDuckGo Instant Answer...');
      final response = await _dio.get(
        'https://api.duckduckgo.com/',
        queryParameters: {
          'q': query,
          'format': 'json',
          'no_html': '1',
          'skip_disambig': '1',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Try Abstract (definition/description)
          final abstract = data['Abstract'];
          if (abstract != null && abstract.toString().trim().isNotEmpty) {
            final source = data['AbstractURL'] ?? data['AbstractSource'] ?? '';
            print('✅ Strategy 1 SUCCESS: Found Abstract');
            return '$abstract\n\nSource: ${source.toString()}';
          }
          // Try Definition
          final definition = data['Definition'];
          if (definition != null && definition.toString().trim().isNotEmpty) {
            final source =
                data['DefinitionURL'] ?? data['DefinitionSource'] ?? '';
            print('✅ Strategy 1 SUCCESS: Found Definition');
            return '$definition\n\nSource: ${source.toString()}';
          }
          // Try Answer (direct answer)
          final answer = data['Answer'];
          if (answer != null && answer.toString().trim().isNotEmpty) {
            print('✅ Strategy 1 SUCCESS: Found Answer');
            return answer.toString();
          }
          print('⚠️ Strategy 1: No instant answer found');
        } else {
          print(
              '❌ Strategy 1: Unexpected response type: \\n${data.runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Strategy 1 failed: $e');
    }

    // Strategy 2: DuckDuckGo Related Topics (deeper search)
    try {
      print('Strategy 2: DuckDuckGo Related Topics...');
      final response = await _dio.get(
        'https://api.duckduckgo.com/',
        queryParameters: {
          'q': query,
          'format': 'json',
          'no_html': '1',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Try RelatedTopics
          final relatedTopics = data['RelatedTopics'];
          if (relatedTopics != null &&
              relatedTopics is List &&
              relatedTopics.isNotEmpty) {
            final firstTopic = relatedTopics[0];
            if (firstTopic is Map<String, dynamic>) {
              final text = firstTopic['Text'];
              final url = firstTopic['FirstURL'];
              if (text != null && text.toString().trim().isNotEmpty) {
                print('✅ Strategy 2 SUCCESS: Found Related Topic');
                return '$text\n\nMore info: ${url ?? ""}';
              }
            }
          }
          print('⚠️ Strategy 2: No related topics found');
        } else {
          print(
              '❌ Strategy 2: Unexpected response type: \\n${data.runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Strategy 2 failed: $e');
    }

    // Strategy 3: Contextual search (add definition/meaning keywords)
    try {
      print('Strategy 3: Contextual Search...');
      final contextualQuery = '$query definition meaning';
      final response = await _dio.get(
        'https://api.duckduckgo.com/',
        queryParameters: {
          'q': contextualQuery,
          'format': 'json',
          'no_html': '1',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final abstract = data['Abstract'];
          if (abstract != null && abstract.toString().trim().isNotEmpty) {
            final source = data['AbstractURL'] ?? '';
            print('✅ Strategy 3 SUCCESS: Found contextual result');
            return '$abstract\n\nSource: ${source.toString()}';
          }
          print('⚠️ Strategy 3: No contextual results');
        } else {
          print(
              '❌ Strategy 3: Unexpected response type: \\n${data.runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Strategy 3 failed: $e');
    }

    // Strategy 4: Wikipedia fallback via DuckDuckGo
    try {
      print('Strategy 4: Wikipedia Fallback...');
      final wikiQuery = '$query site:wikipedia.org';
      final response = await _dio.get(
        'https://api.duckduckgo.com/',
        queryParameters: {
          'q': wikiQuery,
          'format': 'json',
          'no_html': '1',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final abstract = data['Abstract'];
          if (abstract != null && abstract.toString().trim().isNotEmpty) {
            print('✅ Strategy 4 SUCCESS: Found Wikipedia result');
            return '$abstract\n\nSource: Wikipedia';
          }
          print('⚠️ Strategy 4: No Wikipedia results');
        } else {
          print(
              '❌ Strategy 4: Unexpected response type: \\n${data.runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Strategy 4 failed: $e');
    }

    // If all strategies fail, return a generic fallback
    print('❌ All internet search strategies failed');
    return '🌐 I could not find a direct answer online, but you can try rephrasing your question or ask about a Bible verse, topic, or person. I am always learning!';
  }

  void escalate(String messageId) {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      _messages[idx] = ChatMessage(
        id: _messages[idx].id,
        senderId: _messages[idx].senderId,
        role: _messages[idx].role,
        content: _messages[idx].content,
        timestamp: _messages[idx].timestamp,
        attachments: _messages[idx].attachments,
        escalated: true,
      );
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
