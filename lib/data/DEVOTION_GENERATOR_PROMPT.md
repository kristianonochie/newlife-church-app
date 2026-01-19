# Devotion Generator Template & Prompt

## INSTRUCTIONS FOR USING WITH ChatGPT/Claude

Copy the prompt below and paste it into ChatGPT/Claude. It will generate comprehensive devotions in the exact format needed.

---

## SYSTEM PROMPT FOR LLM

Generate 365 Christian devotions for the year 2026 (Jan 1 - Dec 31) in Dart/Flutter list format. Each devotion must follow this EXACT structure:

```
{'date': 'YYYY-MM-DD', 'title': 'Devotion Title', 'scripture': 'Bible Verse Reference', 'body': 'COMPREHENSIVE MERGED CONTENT HERE', 'thoughts': 'Reflection question', 'action': 'Practical application', 'confession': 'Prayer response', 'author': 'New Life Community Church'}
```

## FORMAT REQUIREMENTS

**CRITICAL: The `body` field must be COMPREHENSIVE and EXPOUNDED. It must:**
- Integrate story + teaching into ONE merged field (NO separate 'story' field)
- Be 400-800 words minimum
- Follow this structure:
  1. Opening Scripture reference
  2. Real-world story illustrating the theme (200-300 words)
  3. Deep theological teaching explaining the scripture (200-300 words)
  4. Practical implications and life application (100-150 words)
- Use \n\n to separate paragraphs
- Use \' for apostrophes (not single quotes)
- Escape backslashes in scripture references

**OTHER FIELDS:**
- `thoughts`: Reflection question (1-2 sentences)
- `action`: Specific, actionable application (1-2 sentences)
- `confession`: Prayer/confession response (1-2 sentences)
- `author`: Always 'New Life Community Church'

## EXAMPLE FORMAT (FOLLOW THIS EXACTLY)

```dart
{'date': '2026-02-14', 'title': 'Love Is Patient', 'scripture': '1 Corinthians 13:4', 'body': '1 Corinthians teaches that love is patient. Love does not rush or get frustrated.\\n\\nSarah was impatient with her daughter. She would get angry when her child moved slowly. Then Sarah got sick. Her daughter sat with her for months, patient and kind. Watching her daughter\\'s patience shattered Sarah\\'s pride. She realized her own impatience had cost her so much.\\n\\nPaul\\'s definition of love in 1 Corinthians 13 begins with patience because impatience destroys relationships. Patience is the foundation. When you are patient with someone, you are saying their worth exceeds your convenience. You are willing to wait. You are willing to listen. You are willing to be inconvenienced for their benefit. This is the heart of Christ\\'s love for us. He is infinitely patient with our slowness to grow, our resistance to change, our repeated failures. His patience is not weakness; it is strength.\\'\\n\\nToday, practice patience with someone who tests you. Let their slow pace teach you about Christ\\'s patience with you. Your impatience may be costing you more than you realize.', 'thoughts': 'Where are you impatient in your relationships? How might patience strengthen them?', 'action': 'Identify one person who tests your patience. Be deliberately patient with them today.', 'confession': 'Jesus, You are patient with me. Help me to extend that same patience to others. Amen.', 'author': 'New Life Community Church'}
```

## KEY THEMES TO CYCLE THROUGH (use these throughout the year)

- LOVE (sacrifice, kindness, forgiveness, serving others, unity)
- FAITH (trusting God, overcoming doubt, standing firm, perseverance)
- HOPE (future glory, promises kept, new beginnings, redemption)
- GRACE (unearned favor, forgiveness, transformation, freedom)
- JOY (finding joy in trials, celebration, gratitude, contentment)
- RIGHTEOUSNESS (living according to God\\'s values, integrity, standing for truth)
- TRUTH (knowing Scripture, wisdom, discernment, living authentically)
- PRAYER (communication with God, persistence in prayer, faith-filled asking)
- COMMUNITY (bearing one another\\'s burdens, accountability, unity, loving neighbors)
- TRANSFORMATION (becoming like Christ, renewal, sanctification, growth)

## INSTRUCTIONS FOR GENERATION

1. Generate devotions for the following dates: **[LIST DATES NEEDED]**
2. Ensure each has a unique real-world story (different characters, different scenarios)
3. Ensure deep, expounded theological teaching (not summarized)
4. Alternate themes throughout to maintain variety
5. Match the spiritual calendar (Christmas themes in December, Resurrection themes around Easter, etc.)
6. Output as a valid Dart list that can be copied directly into the file

## OUTPUT FORMAT

Generate output that looks like this:

```dart
  {'date': '2026-02-04', 'title': 'TITLE', 'scripture': 'REFERENCE', 'body': '...', 'thoughts': '...', 'action': '...', 'confession': '...', 'author': 'New Life Community Church'},
  {'date': '2026-02-05', 'title': 'TITLE', 'scripture': 'REFERENCE', 'body': '...', 'thoughts': '...', 'action': '...', 'confession': '...', 'author': 'New Life Community Church'},
```

## IMPORTANT NOTES

- Each devotion should be spiritually substantial and theologically sound
- Stories should be realistic and relatable (not preachy)
- Teaching should be educational but accessible (not overly academic)
- All prayers (confessions) should be heartfelt and personal
- Dates must be in YYYY-MM-DD format
- Escape all apostrophes as \\'
- Use \\n\\n for paragraph breaks in the body field
- NO line breaks within field values (keep each devotion on one line)

---

## HOW TO USE THIS

1. Copy this entire section below to ChatGPT/Claude:

```
SYSTEM INSTRUCTION: You are a Christian devotion writer for New Life Community Church. Generate Christian devotions following this exact format for these dates:

[DATES TO GENERATE - e.g., February 4-28, 2026]

REQUIRED FORMAT:
Each devotion MUST have:
- date (YYYY-MM-DD)
- title (compelling, theme-based)
- scripture (exact Bible verse reference)
- body (400-800 words, story + teaching merged together with \\n\\n between paragraphs)
- thoughts (reflection question)
- action (practical application)
- confession (prayer)
- author ('New Life Community Church')

STRUCTURE OF BODY FIELD:
1. Scripture quote
2. Real-world story (200-300 words) with named character experiencing the truth
3. Deep theological teaching (200-300 words) explaining what the scripture means
4. Practical application (100-150 words) showing how to live it today

OUTPUT: Dart list format, one devotion per line, properly escaped.
```

2. Add the dates you want generated
3. ChatGPT will generate comprehensive devotions
4. Copy the output
5. Paste into the devotions_2026_complete.dart file to replace placeholder entries

---

## DATES CURRENTLY NEEDED (Update as you complete them)

### JANUARY 2026
- [x] Jan 1-3 (expanded manually)
- [x] Jan 15, 17 (expanded manually)
- [ ] Jan 4-14, 16, 18-31 (Need to generate - 24 devotions)

### FEBRUARY 2026
- [ ] Feb 1-28 (Need to generate - 28 devotions)

### MARCH 2026
- [ ] Mar 1-31 (Need to generate - 31 devotions)

### APRIL 2026
- [ ] Apr 1-30 (Need to generate - 30 devotions)

### MAY 2026
- [ ] May 1-31 (Need to generate - 31 devotions)

### JUNE 2026
- [ ] Jun 1-30 (Need to generate - 30 devotions)

### JULY 2026
- [ ] Jul 1-31 (Need to generate - 31 devotions)

### AUGUST 2026
- [ ] Aug 1-31 (Need to generate - 31 devotions)

### SEPTEMBER 2026
- [ ] Sep 1-30 (Need to generate - 30 devotions)

### OCTOBER 2026
- [ ] Oct 1-31 (Need to generate - 31 devotions)

### NOVEMBER 2026
- [ ] Nov 1-30 (Need to generate - 30 devotions)

### DECEMBER 2026
- [ ] Dec 1-31 (Need to generate - 31 devotions)

**TOTAL DEVOTIONS NEEDED: 335** (365 - 30 already expanded)

---

## NEXT STEPS

1. **Use ChatGPT/Claude** with dates Feb 1-28, 2026 to generate February devotions
2. Copy the Dart list output
3. I will integrate them into the devotions_2026_complete.dart file
4. Repeat for remaining months

This approach will generate all 365 devotions efficiently while maintaining the comprehensive, expounded quality you specified!
