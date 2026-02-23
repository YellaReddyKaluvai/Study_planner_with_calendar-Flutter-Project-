# Getting Started with Enhanced Study Planner 🎯

## Quick Setup (2 minutes)

### Step 1: Run the App
```bash
cd study_planner_with_calendar
flutter pub get
flutter run
```

### Step 2: Notice the New Features
1. **Dashboard** - Now shows real analytics charts! 📊
2. **Timer Button** - New ⏱️ icon in top-right of dashboard
3. **Streak Display** - See your current streak in stats

---

## Using the Focus Timer ⏱️

### Starting a Session
1. Click the **⏱️ timer icon** on the dashboard
2. Choose a preset: 🍅 Pomodoro, 🧠 Deep Work, ⚡ Quick Focus, 💪 Marathon
3. Click **Play** button to start
4. Timer automatically saves your session when complete

### During a Session
- **Pause** ⏸️ - Pause and resume anytime
- **Stop** ⛔ - End early (will still save time spent)
- Watch progress in the circular indicator
- Add time or use presets to adjust duration

### After Completion
- Timer automatically records your session
- Session data appears in analytics dashboard
- Your streak updates if you studied today

---

## Understanding Analytics 📊

### Weekly Chart
Shows your study time for each day:
- **Green/Blue bars** - Total minutes studied that day
- **Height** - Indicates more study time
- Scroll back to see historical data

### Quick Stats
- **Tasks Done** - Number of tasks completed (preset: 12)
- **Focus Time** - Total time in focus sessions (preset: 4h 20m)
- **Current Streak** - Days of consecutive study 🔥

### Top Subjects
- Lists your most-studied subjects this week
- Progress bars show relative time spent
- Helps identify focus areas

---

## Streak System 🔥

### How Streaks Work
1. **Day 1** - Study for any amount → Streak = 1
2. **Day 2** - Study again → Streak = 2
3. **Miss a day** → Streak resets to 0
4. **Freeze** - Bonus item: Skip one missed day without losing streak

### Badges & Milestones
Reach these milestones to unlock badges:
- 🔥 **7 Days** - Week Warrior (+10 XP)
- ⭐ **30 Days** - Month Master (+50 XP + Freeze)
- 👑 **100 Days** - Century Champion (+250 XP + Badge)
- ✨ **365 Days** - Golden Scholar (+1000 XP + Platinum)

### Tips to Maintain Streak
- ✅ Schedule regular study time (e.g., 9-10 AM daily)
- ✅ Use the timer to maintain consistency
- ✅ Save streak freezes for emergencies (illness, travel)
- ✅ Set a reminder notification daily

---

## Productivity Score 📈

Your **Productivity Score** (0-100%) shows how close you are to your weekly goal:

- **90-100%** - 🟢 Exceptional
- **75-89%** - 🟢 Excellent  
- **60-74%** - 🟡 Good
- **40-59%** - 🟠 Fair
- **Below 40%** - 🔴 Needs Improvement

**Target**: 300 minutes (5 hours) per week

### Example
- Study 150 min this week = 50% score (Fair)
- Study 225 min this week = 75% score (Excellent)
- Study 300+ min this week = 100% score (Exceptional)

---

## Daily Workflow 🗓️

### Recommended Schedule
1. **Morning** - Check dashboard, see today's streak and score
2. **Study Time** - Click timer, choose preset, start session
3. **Throughout Day** - Start new timer sessions as needed
4. **Evening** - Review analytics, plan tomorrow's sessions

### Example Day
```
9:00 AM  - Start 25-min Pomodoro (Math)
10:00 AM - See analytics update automatically
12:00 PM - Start 50-min Deep Work (Physics)
3:00 PM  - Quick 5-min review session
6:00 PM  - Check streak, see "Examined Math & Physics today! Streak: 15🔥"
```

---

## Data & Privacy 🔐

### What Gets Saved
- Study session duration
- Subject name
- Start/end times
- Focus quality rating
- Tasks completed count
- Session notes (optional)

### Where It's Stored
- **Phone** - Local SQLite database (offline access)
- **Cloud** - Firebase (optional sync)
- **Encrypted** - All data is secure

### Delete History
- Wipe analytics: Settings → Clear Data
- Note: This cannot be undone!

---

## Tips & Tricks 💡

### Pro Tips
1. **Set a Regular Time** - Study at same time each day for consistency
2. **Use Deep Work** - For complex subjects that need focus
3. **Quick Focus** - For rapid Q&A or reviews
4. **Track Subjects** - See which subjects get most time
5. **Experiment** - Try different timer durations to find your sweet spot

### Productivity Hacks
- 🍅 **Pomodoro Power** - 4 pomodoros = ~2 hour effective study session
- 🧠 **Deep Work** - Save for complex problem-solving
- 📊 **Weekly Review** - Check analytics every Sunday
- 🔥 **Streak Motivation** - Tell friends about your streak!
- 📌 **Subject Balance** - Try to study different subjects

---

## Troubleshooting ❓

### Q: Timer not showing on dashboard?
**A:** Make sure app initialized properly. Restart the app.

### Q: Sessions not saving to analytics?
**A:** Check you hit "Save & Exit" button when stopping timer.

### Q: Streak reset unexpectedly?
**A:** Streaks reset if you don't study for a full day. Use Freeze if needed.

### Q: Where's my data?
**A:** Check:
1. Dashboard → Analytics section → Scroll down
2. Make sure you've completed at least one timer session
3. Data appears immediately after saving

### Q: Can I delete a wrong session?
**A:** Currently: Not individually. Use Clear Data to reset all.
Future: Session edit/delete coming soon!

---

## Feature Requests 🚀

Want something new?
- AI-powered recommendations
- Study groups & leaderboards
- Calendar integration
- Export analytics as PDF
- Voice study notes

Let the developers know! 📧

---

## Next Steps 🎓

1. ✅ Try the Focus Timer (25-min Pomodoro)
2. ✅ Study for 2-3 days and watch streak grow
3. ✅ Check analytics dashboard to see patterns
4. ✅ Set a weekly productivity goal
5. ✅ Reach your first milestone! 🎉

---

### Questions?
Check `ENHANCEMENTS.md` for technical details or explore the app's features!

**Happy studying! 📚🔥**
