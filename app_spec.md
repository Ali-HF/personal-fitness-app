# Ali's Fitness App: Plan, Workout Library & Antigravity Prompt (v2)

Goal: finish a half marathon comfortably (race default: Sun 3 Jan 2027, editable) and run a controlled 5k test on Thu 17 Dec 2026 (target sub-30; sub-20 is a long-term goal tracked in the app).
Body goals: lose fat toward about 65 kg (currently about 76 kg at 5'9") while keeping muscle, lean out the face through overall fat loss, and fix a hunched posture (see the Posture routine and Body & fuel guidance in Part 3).
Constraints: home workouts only (2 x 10 kg dumbbells, pull-up bar), max 1 hour, mornings. Finals 3-15 Dec. Mondays = Collabspace internship (rest or very light).
Starting point: no running for a month, no gym for 2 months. First weeks are deliberately gentle.

What changed in v2: smoother long-run progression, proper leg strength (Leg A / Leg B), a gentler 5k test, readiness check-ins, pacing from the 5k test, and an Export & Share feature so the first week of data can be reviewed and the plan updated.

Honest caveat: with a Jan 3 race this is a compressed build (about 9 weeks) for a restart. The peak long run (12 km) is well below the roughly 16 km (10 miles) that Hal Higdon's 12-week novice half-marathon plan reaches, and research on recreational half-marathoners links higher weekly volume and longer long runs with faster finishes, so expect to slow in the second half. The evidence also favors a taper of about 2 weeks (8-14 days), and Jan 3 only allows 8 days. The plan compensates with run/walk, easy pacing and readiness checks, but if the race date is flexible, Option B (race Jan 17) or Option C (race Jan 24), both below, are clearly safer and stronger. Option C reaches a 15 km peak long run and a full 2-week taper.

---

## PART 1: Weekly template

| Day | Default session |
|---|---|
| Mon | Leg B (light, 12-15 min) + mobility. Collabspace day, keep it short |
| Tue | Easy run |
| Wed | Upper A (pull + core) + Leg A (strength, 15 min) |
| Thu | Quality run (intervals / tempo) |
| Fri | Upper B (push + core), no heavy leg work |
| Sat | Long run |
| Sun | Optional Upper C (skills/light) or mobility |

Daily: Posture routine (8-10 min, see Part 3). On MOB days it replaces the mobility session. On Wednesdays (Upper A + Leg A) do it in the evening or shorten Leg A to 10 min, so the morning stays under 60 min.

Run intensity is by feel until the 5k test gives real numbers:
- **Easy** = you can speak full sentences.
- **Comfortably hard** = short phrases only, controlled, not a sprint.
- **Tempo** = hard but steady, a few words at a time.

---

## PART 2: Week-by-week plan (source of truth for plan.json)

Codes: UA/UB/UC = upper sessions, LEG-A / LEG-B = leg sessions, RW = run/walk, EASY, INT, TEMPO, LONG, TEST5K, SHAKE, MOB, REST.

### Week 1: Nov 4-8 (restart; 2 sets on strength work, bodyweight on Leg A)
| Date | Session |
|---|---|
| Wed Nov 4 | UA (2 sets) + LEG-A (bodyweight, 2 sets) |
| Thu Nov 5 | RW1: 5' brisk walk, 8 x (2' jog / 1' walk), 5' walk |
| Fri Nov 6 | UB (2 sets) |
| Sat Nov 7 | RW2: 5' walk, 8 x (3' jog / 1' walk), 5' walk (about 4 km) |
| Sun Nov 8 | REST (PS assignment) |

### Week 2: Nov 9-15 (Space Apps weekend, so the long run moves to Friday)
| Date | Session |
|---|---|
| Mon Nov 9 | LEG-B (glute bridges and calf raises only) + REST otherwise (holiday + internship) |
| Tue Nov 10 | RW3: 5' walk, 5 x (4' jog / 1' walk), 5' walk |
| Wed Nov 11 | UA (2 sets) + LEG-A (bodyweight, 2 sets) |
| Thu Nov 12 | RW4: 5' walk, 5 x (5' jog / 1' walk), 5' walk |
| Fri Nov 13 | LONG: 5 km, run 6' / walk 1' as needed |
| Sat Nov 14 | MOB 15 min |
| Sun Nov 15 | MOB / optional UC |

### Week 3: Nov 16-22
| Date | Session |
|---|---|
| Mon Nov 16 | LEG-B (adds 2 x 15 pogo hops) |
| Tue Nov 17 | EASY 30' continuous (walk breaks allowed) |
| Wed Nov 18 | UA (3 sets) + LEG-A (add 10 kg dumbbell where possible, 3 sets) |
| Thu Nov 19 | INT-1: 10' easy jog, 5 x (1' comfortably hard / 2' easy jog), 10' easy |
| Fri Nov 20 | UB (3 sets) |
| Sat Nov 21 | LONG 6 km easy |
| Sun Nov 22 | UC optional / MOB |

### Week 4: Nov 23-29
| Date | Session |
|---|---|
| Mon Nov 23 | LEG-B |
| Tue Nov 24 | EASY 35' |
| Wed Nov 25 | UA (3-4 sets) + LEG-A (3 sets) |
| Thu Nov 26 | INT-2: 10' easy jog, 4 x (3' comfortably hard / 2' easy jog), 10' easy |
| Fri Nov 27 | UB (3-4 sets) |
| Sat Nov 28 | LONG 7 km easy |
| Sun Nov 29 | UC optional / MOB |

### Week 5: Nov 30-Dec 6 (FINALS MODE starts)
| Date | Session |
|---|---|
| Mon Nov 30 | REST |
| Tue Dec 1 | EASY 30' |
| Wed Dec 2 | Finals Mini (20 min) + LEG-A (2 sets, 10 min) |
| Thu Dec 3 | REST: Civics final |
| Fri Dec 4 | EASY 25' + 4 x 20" strides |
| Sat Dec 5 | REST/MOB: Ethics exam |
| Sun Dec 6 | LONG 8 km easy |

### Week 6: Dec 7-13 (finals)
| Date | Session |
|---|---|
| Mon Dec 7 | REST |
| Tue Dec 8 | MOB 10': DSA exam |
| Wed Dec 9 | EASY 30' |
| Thu Dec 10 | REST: PS exam |
| Fri Dec 11 | EASY 30' + 4 strides |
| Sat Dec 12 | REST: ARW exam |
| Sun Dec 13 | LONG 9 km easy |

### Week 7: Dec 14-20 (finals end Dec 15)
| Date | Session |
|---|---|
| Mon Dec 14 | REST |
| Tue Dec 15 | REST: LADE exam |
| Wed Dec 16 | UA (light, stop 2 reps before failure) + LEG-A (3 sets) |
| Thu Dec 17 | **5K TEST** (controlled, not all-out): 10' easy jog + 4 strides, 5 km at comfortably-hard steady effort (about 8/10, finish feeling you could do another minute), 10' walk |
| Fri Dec 18 | REST / MOB |
| Sat Dec 19 | EASY 30' |
| Sun Dec 20 | LONG 10.5 km easy |

### Week 8: Dec 21-27 (peak week)
| Date | Session |
|---|---|
| Mon Dec 21 | LEG-B (last one) |
| Tue Dec 22 | EASY 40' |
| Wed Dec 23 | UA (3 sets) + LEG-A (last one, 2-3 sets) |
| Thu Dec 24 | TEMPO: 10' easy, 2 x 10' tempo with 3' jog between, 10' easy |
| Fri Dec 25 | UB (2-3 sets, light) |
| Sat Dec 26 | LONG 12 km easy (peak), use the race-day run/walk pattern |
| Sun Dec 27 | MOB / optional UC |

### Week 9: Dec 28-Jan 3 (taper + race, no leg strength this week)
| Date | Session |
|---|---|
| Mon Dec 28 | REST |
| Tue Dec 29 | EASY 30' + 4 strides |
| Wed Dec 30 | UA light (2 sets, no failure) |
| Thu Dec 31 | EASY 20' including 3 x 1' comfortably hard (keeps intensity, cuts volume) |
| Fri Jan 1 | REST or UC very light |
| Sat Jan 2 | SHAKE: 15' easy + 3 strides |
| Sun Jan 3 | **RACE DAY: HALF MARATHON** (date editable in settings) |

Long-run progression: 4, 5, 6, 7, 8, 9, 10.5, 12 km. After the first two weeks each step is about 12-17%.

Race plan: use run/walk from the start. One study of 42 recreational marathoners used a 1-minute walk every 1.5 miles (about 2.4 km) and found similar finish times with less muscle pain. Because you are less trained, start more generously (for example run 8' / walk 1') and test it on the Dec 20 and Dec 26 long runs. Start slower than feels necessary for the first 5 km, drink to thirst (do not force fluids), eat only familiar food, nothing new on race day. Expect to slow in the second half: in a Dutch cohort, half-marathoners with shorter longest runs slowed more during the race. Finish estimate: the app uses the 5k test with the Riegel formula, then adds 5-15% for limited long-run volume and walk breaks (about 2:30-2:50 for a 30-32 min 5k).

### Option B: race Sun Jan 17 (weeks 1-8 identical; weeks 9-11 replace the Jan 3 taper)
Peak long run 13.5 km on Jan 2, then a 2-week taper.

| Date | Session |
|---|---|
| Mon Dec 28 | LEG-B (last one) |
| Tue Dec 29 | EASY 40' |
| Wed Dec 30 | UA (3 sets) + LEG-A (last one, 2 sets) |
| Thu Dec 31 | INT-2: 10' easy jog, 4 x (3' comfortably hard / 2' easy jog), 10' easy |
| Fri Jan 1 | UB (2-3 sets, light) |
| Sat Jan 2 | LONG 13.5 km easy (peak), use race run/walk pattern |
| Sun Jan 3 | MOB |
| Mon Jan 4 | REST |
| Tue Jan 5 | EASY 30' + 4 strides |
| Wed Jan 6 | UA light (2 sets, no failure) |
| Thu Jan 7 | EASY 25' including 3 x 1' comfortably hard |
| Fri Jan 8 | REST |
| Sat Jan 9 | LONG 8 km easy (taper week 1, about 40% less volume than peak week) |
| Sun Jan 10 | MOB |
| Mon Jan 11 | REST |
| Tue Jan 12 | EASY 25' + 4 strides |
| Wed Jan 13 | UA very light (2 sets, no failure) |
| Thu Jan 14 | EASY 20' including 3 x 1' comfortably hard |
| Fri Jan 15 | REST |
| Sat Jan 16 | SHAKE: 15' easy + 3 strides |
| Sun Jan 17 | **RACE DAY: HALF MARATHON** |

### Option C: race Sun Jan 24 (recommended if the date is flexible)
Weeks 1-8 identical. Peak long run 15 km on Jan 9, then a 2-week taper.

| Date | Session |
|---|---|
| Mon Dec 28 - Sun Jan 3 | Same as Option B (long run 13.5 km on Sat Jan 2) |
| Mon Jan 4 | LEG-B (last one) |
| Tue Jan 5 | EASY 40' |
| Wed Jan 6 | UA (3 sets) + LEG-A (last one, 2 sets) |
| Thu Jan 7 | TEMPO: 10' easy, 2 x 10' tempo with 3' jog between, 10' easy |
| Fri Jan 8 | UB (2-3 sets, light) |
| Sat Jan 9 | LONG 15 km easy (peak), use race run/walk pattern |
| Sun Jan 10 | MOB |
| Mon Jan 11 - Sun Jan 17 | Taper week 1: same as Option B's Jan 4-10 (long run 8 km on Sat Jan 16) |
| Mon Jan 18 - Sun Jan 24 | Taper week 2: same as Option B's Jan 11-17, race on Sun Jan 24 |

Long-run progression for C: 4, 5, 6, 7, 8, 9, 10.5, 12, 13.5, 15 km (steps of about 11-17% after the first two weeks).

---

## PART 3: Workout library

### Upper A: Pull + Core (about 40-45 min)
Warm-up (5'): arm circles, scapular pull-ups, cat-cow, towel shoulder dislocates
1. Pull-ups: 4 x (max minus 2 reps), rest 2'. Regressions: chin-ups, slow negatives (5s down), scapular pull-ups, dead hangs.
2. One-arm dumbbell row (10 kg): 3 x 10 per side, 2s up / 2s down
3. Dumbbell rear-delt fly: 3 x 12
4. Hanging knee raise: 3 x 8-12. Alt: lying leg raise
5. Hollow hold: 3 x 20-30s
6. Dumbbell curl: 2 x 12 (optional)

### Upper B: Push + Core (about 40-45 min)
Warm-up (5'): arm circles, wrist rolls, incline push-ups x 10
1. Push-ups: 4 x (max minus 2). Ladder: incline, standard, feet-elevated, diamond
2. Pike push-up: 3 x 6-10. Alt: dumbbell overhead press (10 kg) 3 x 10
3. Dumbbell floor press: 3 x 12
4. Bench dips on a stable surface: 3 x 10
5. Plank 3 x 40s, side plank 2 x 25s/side
6. Superman: 2 x 12

### Upper C: Skills / Light (25 min, optional)
Dead hang 3 x 20s, scapular pull-ups 3 x 8, easy push-up ladder, L-sit hang practice, 5' mobility

### Leg A: Strength (15 min, Wednesdays, never the day before a long run)
Slow 3s lowering on every rep. Bodyweight in weeks 1-2, then add the 10 kg dumbbells.
1. Rear-foot-elevated split squat (chair behind you): 3 x 8 per leg
2. Single-leg Romanian deadlift (dumbbell in opposite hand): 3 x 8 per leg
3. Single-leg calf raise: straight knee 3 x 12 per leg, then bent knee 2 x 12 per leg
Finals version: 2 sets of each, 10 min.
Progression: when all sets feel easy 2 sessions in a row, add reps to 10-12, then hold the dumbbells closer to a heavier, slower variation (pauses at the bottom).

### Leg B: Light plyometric + stability (12-15 min, Mondays)
Weeks 1-2: single-leg glute bridge 3 x 10 per leg, calf raises 2 x 15. No jumping yet.
From week 3: add pogo hops 2-3 x 15-20, skipping 3 x 20 m, side-step lunges 2 x 8 per side.
Stop and skip jumps if shins, Achilles or knees feel sore.

### Finals Mini (20 min, 3 rounds, no failure)
Pull-ups (comfortable reps), push-ups (comfortable reps), hollow hold 20s, rest 60s between rounds

### Mobility (10-15 min)
Hip flexor stretch, hamstring stretch, calf stretch, pigeon pose, thoracic rotation, shoulder opener

### Posture routine (daily, 8-10 min)
1. Chin tucks: 2 x 10, 3s hold (lying down or against a wall)
2. Doorway pec stretch: 2 x 30s per side
3. Thoracic extension over a rolled towel or chair back: 2 x 8 slow reps
4. Wall slides (wall angels): 2 x 10
5. Prone Y-T-W raises (bodyweight): 1 round of 8 each
6. Scapular pull-ups or dead hang: 2 x 8 (skip on pull-up days)
7. Hip flexor stretch: 2 x 30s per side
Daily habits: stand and reset every 30-45 minutes, raise the laptop or phone screen toward eye level, avoid long stretches with the neck bent forward.
Check progress with a weekly side-view photo in the same spot and clothing. If you have pain, numbness or tingling, or the curve feels stiff and fixed, see a doctor or physiotherapist first.
The strength sessions already favor pulling (rows, pull-ups, rear-delt fly), which also helps.

### Body & fuel guidance (static info card in the app, not medical advice)
- **Target:** about 65 kg while keeping muscle (a healthy BMI at your height, about 21).
- **Rate:** aim for 0.4-0.6 kg per week, never above about 0.75 kg per week (about 1% of body weight). From about 76 kg, 65 kg is 11 kg away. Realistic: about 3.5-5 kg by early January (around 71-72.5 kg), and 65 kg around April if sustained. Your BMI would be about 21 at 65 kg (about 24.7 now).
- **Weigh in** daily or weekly at the same time and judge by the 7-day average, not single days. Add a weekly waist measurement. If you take creatine, it holds a little water, so expect the scale to read slightly higher.
- **Deficit:** modest, about 10-15% below maintenance. Do not stack a big deficit on top of the running build and finals. Adjust by trend: if you lose faster than 0.75 kg per week for 2 weeks, eat about 150-200 kcal more per day; if the average is flat for 2-3 weeks, trim about 100-150 kcal or add walking.
- **Protein:** about 1.6-2.0 g per kg per day (roughly 120-150 g at 76 kg), spread over 3-4 meals of about 20-40 g.
- **Carbs and fueling:** keep enough carbohydrate around runs and eat before runs longer than 60 minutes. Do not go low-carb during the build.
- **Finals (Dec 1-15):** hold at maintenance or a very small deficit.
- **Race week:** no deficit for the last 7-10 days. Eat at maintenance and practice only familiar foods.
- **Face fat:** it comes off with overall fat loss. Local exercise does not remove fat from one spot. Where it comes off first depends on genetics, so be patient.
- **Warning signs of under-fueling:** constant fatigue, worsening sleep, getting sick often, injuries that linger, low mood, constant hunger or preoccupation with weight. If you notice these, eat more and send me an export.

### Progression rule (app logic)
If you hit the top of the rep range on all sets for 2 sessions in a row, move to the next harder variation or add 1 rep per set. Never progress during finals mode or taper.

---

## PART 4: App logic rules

- **Today screen** shows the planned session for the current date, with full exercise or run details.
- **Readiness check-in (30 seconds, shown before the session):** sleep hours, leg soreness 0-10, pain (none / mild / sharp), stress 1-5, optional note.
  - Sharp pain: suggest rest and offer to swap the session. Do not push through pain, and suggest seeing a doctor or physio if it persists.
  - Soreness 7 or higher, or under 6 hours of sleep: suggest the easier version (INT/TEMPO becomes EASY, LONG becomes about 70% of the distance).
  - Chest pain, dizziness or fainting: stop and seek medical care.
- **Long-run cap check:** warn if a planned or logged run is more than 115% of the longest run in the last 30 days. (Research points to single-run jumps, not weekly totals, as the riskier thing. The plan itself uses steps up to about 17%, so the warning is a prompt to be careful, not a hard block.)
- **Swap session:** alternatives depend on type.
  - Run: EASY, RW, a shorter version, rest.
  - Upper: UA, UB, UC, Finals Mini, Mobility.
  - Rule: block two hard days (INT, TEMPO, LONG, TEST5K) back to back, and warn if LONG is moved within 2 days of a hard session or a Leg A session.
- **Swap exercise:** each exercise has regression and progression alternatives from the library.
- **Missed sessions:** mark skipped, never double up. If 2 or more sessions are skipped in a week, offer "Repeat this week".
- **Finals mode:** auto-on for Dec 1-15 (dates editable). Hides INT/TEMPO, caps session length at 30 min, and suggests Finals Mini on non-run days.
- **After the 5k test:** convert the result into training paces (easy pace roughly 60-90 s/km slower than the test pace, long run at easy pace) and show a half-marathon estimate range: Riegel time (T2 = T1 x (D2/D1)^1.06) multiplied by 1.05 (best case) to 1.15 (conservative, for limited long-run volume and walk breaks). Treat all of it as an estimate.
- **Logging:**
  - Strength: sets, reps, added weight (kg), RPE.
  - Runs: distance, duration, average pace, RPE, notes.
- **Progress:** weekly distance chart, long-run trend, pull-up and push-up max over time, 5k test result vs the 20:00 long-term target line.
- **Settings:** race date, finals date range, units, reminders, export and import.

### Body tracker and fuel rules
- Body log: optional daily or weekly weight, weekly waist, optional weekly side-view photo (stored only on the phone). Show the 7-day average weight trend and the weekly rate of change.
- Flag in the app if the 7-day average drops faster than 0.75 kg per week for 2 weeks (suggest eating more), or if it is flat for 2-3 weeks (suggest a small adjustment).
- Hide or soften deficit advice during finals (Dec 1-15) and the last 10 days before the race; show "eat at maintenance".
- If the readiness check-in shows 3 or more low-energy days in a row (fatigue, poor sleep, soreness), suggest eating more and resting.
- Posture routine: a daily checkbox with a link to the routine, plus a weekly photo reminder.

### Export & Share (needed after the first week of data)
Settings > Export for review.
1. Pick a range (default: last 7 days) and tap Export. The app generates:
   - A readable **summary** (Markdown text): per-day table of planned vs done vs skipped vs swapped (with swap reasons), run logs, strength logs with top sets vs targets, readiness check-ins (sleep, soreness, pain), body log (7-day average weight, waist), posture routine adherence, notes, weekly totals (km, sessions done %), and flags (long-run cap warnings, skipped hard sessions).
   - A full **JSON** file with the same data in structured form, plus app version, plan version, race date and settings.
2. Buttons: **Share** (Android share sheet, so it can be sent straight to Claude as a file) and **Copy summary** (to paste as text).
3. **Backup / Import:** export the full JSON as a backup; import it on a new phone.
4. Optional weekly reminder, Sunday 8 pm: "Export this week for review". Toggle in Settings.
5. Data stays on the phone and is only shared when you tap Share. GPS routes are not included by default.

---

## PART 5: Antigravity prompt (copy everything in this block)

```
You are building a personal fitness app for me in Flutter, targeting Android. I will run it on my own phone over USB. Build in tiers. Finish Tier 1, make sure it runs, then stop and wait for my review before starting Tier 2.

CONTEXT
- One user (me). No backend, no accounts. All data is stored locally on the device.
- The app trains me for a 5k test on 17 Dec 2026 and a half marathon. Home workouts only: two 10 kg dumbbells and a pull-up bar.
- The plan has three race-date variants: Jan 3 (default), Option B Jan 17, Option C Jan 24. They share Weeks 1-8 and differ afterwards. Settings has a plan variant selector.
- Source of truth for the plan and workouts: the attached spec file (Parts 2, 3 and 4). Convert them into assets/plan.json (all three variants) and assets/workouts.json. Do not invent sessions.

DESIGN & UX (follow exactly; it must feel like a polished, shipped app, not a generated prototype)
Reference approach: borrow the proven patterns used by popular fitness apps (bottom tab navigation, a hero "today" card, week date strip, set-by-set logging table with check buttons, big-number run screen). Do NOT copy any specific app's logos, icons, illustrations, copy or exact layout. The look below is our own.

Themes: light (default) and dark, following system with a manual toggle in Settings.
Light: background #FAF6EA (cream), surface #FFFFFF, surface-alt #F3ECD6, primary #F5B800 (yellow), on-primary #1A1A17 (dark text on yellow, never white), text #1C1B17, text-secondary #6B665A, divider #E8E0C8.
Dark: background #0F0F0E, surface #1A1A18, surface-alt #242421, primary #FFC82C, on-primary #14120A, text #F5F1E6, text-secondary #A39E8E, divider #2E2D28.
Status colors used sparingly: done #4C9A5B, hard-session #D9694F. Everything else is cream/white/yellow/black.
Define all colors once as ThemeData / ColorScheme tokens. No hardcoded colors in widgets. No default Material purple, no rainbow gradients.

Type and spacing: one font family (DM Sans via google_fonts), a fixed type scale (Display 32, Title 22, Subtitle 17, Body 15, Caption 12), tabular figures for timers, pace and distance. 8-pt spacing grid, 16-20 px screen padding. Card radius 20, button radius 16, primary button height 56. Prefer 1 px dividers and subtle borders over heavy shadows. Icons: a single consistent icon set (phosphor_flutter), never emoji as icons.

Navigation: bottom bar with 4 tabs (Today, Plan, Progress, Settings). Active workout and live run are full-screen routes pushed over the tabs.

Screens and flow
- Today: greeting and date, a Mon-Sun week strip (dots for done / planned / rest), a readiness check-in card (sleep, leg soreness, pain, stress), a daily posture routine checkbox, a hero card for today's session (type chip, title, duration or distance, 3-4 exercise preview lines, big yellow "Start" button, secondary "Swap" button), a "This week" summary row (sessions done, km run), an "Up next" card, and a "days to half marathon" countdown.
- Session detail: header, then an exercise list showing sets x reps; tap an exercise to open a bottom sheet with its regression and progression swaps.
- Active strength workout: current exercise on top, a table of set rows (set number, previous result, kg, reps, check button), add-set button, automatic rest timer in a bottom bar, "Finish" button.
- Run (Tier 1): manual log form with large numeric inputs for distance and time, pace calculated live. Run (Tier 2): live screen with huge time / distance / pace, a run-vs-walk phase indicator, pause/resume, long-press to finish.
- Finish screen: summary card, RPE selector (1-10 slider), notes field, save.
- Plan: week and month calendar; tap a day to see or swap its session.
- Progress: stat tiles on top, then charts (weekly distance, long-run trend, strength maxes, 5k test vs 20:00 target line) and a Body & Fuel sub-screen (7-day average weight trend, waist, optional progress photos stored locally, and the static fuel guide).
- Settings: theme, race date, finals dates, units, reminders, Export & Share.
- Every list/screen has a proper empty state and loading state.

Polish: haptic feedback on set check, start and finish; 200-300 ms transitions; bottom sheets with a drag handle; safe-area aware; large tap targets (48 px minimum); supports system text scaling; WCAG AA contrast (check text on yellow); keep the screen awake during workouts and runs.

STACK
- Flutter (latest stable), Dart null safety
- UI: google_fonts, phosphor_flutter
- State management: Riverpod
- Local database: sqflite or drift, plus path_provider
- Charts: fl_chart
- Notifications: flutter_local_notifications
- Export/share: share_plus (share files and text), file_picker (import backup)
- Tier 2 only: geolocator (with Android foreground service notification for background tracking), wakelock_plus, permission_handler, flutter_map with OpenStreetMap tiles (no API key)

DATA MODEL
- PlannedSession: id, date, type (UA/UB/UC/LEG_A/LEG_B/RW/EASY/INT/TEMPO/LONG/TEST5K/SHAKE/MOB/REST/RACE/FINALS_MINI), title, details (structured steps for runs, exercise list for strength)
- Exercise: id, name, movement pattern, target sets/reps, regressions[], progressions[]
- WorkoutLog: id, date, sessionId, type, notes, RPE, plus strength sets (exercise, set number, reps, weight kg) or run data (distance km, duration, avg pace)
- ReadinessCheckIn: date, sleepHours, legSoreness (0-10), pain (none/mild/sharp), stress (1-5), note
- SessionChange: date, originalSessionId, replacement (or skipped), reason
- BodyLog: date, weightKg (optional), waistCm (optional), photoPath (optional, local only), note
- PostureLog: date, routineDone (bool), minutes
- Settings: planVariant (JAN_3 / JAN_17 / JAN_24), raceDate, finalsStart, finalsEnd, units, theme, reminders

TIER 1 (build first)
1. Today screen: today's planned session in full detail, with a clear Start / Log button.
2. Readiness check-in with the suggestion rules in Part 4 of the spec.
3. Swap session: valid alternatives following the swap rules in Part 4, including blocking back-to-back hard days.
4. Swap exercise: replace any exercise with its regression or progression.
5. Log a workout: strength (sets/reps/weight/RPE) and run (manual distance, time, pace, RPE).
6. Plan calendar: week view and full-plan list through race day, with done / skipped / planned / swapped states.
7. Finals mode: auto-on for the finals date range, with the rules in Part 4.
8. Missed-session handling and "Repeat this week".
9. Long-run cap warning (115% of the longest run in the last 30 days).
10. Export & Share exactly as described in Part 4 of the spec: summary (Markdown) + full JSON, Share and Copy buttons, backup/import, optional Sunday reminder.
11. Settings screen for plan variant, race date, finals dates, theme, units, reminders.
12. Daily posture routine: a checkbox on the Today screen that opens the routine from Part 3, plus a weekly photo reminder.
13. Body tracker: log weight, waist and optional photo; show the 7-day average trend, weekly rate of change and the flags in Part 4.
14. Static "Body & fuel" info card with the guidance in Part 3 (informational only, no calorie tracking).
15. Implement the DESIGN & UX section above exactly: light cream/yellow theme, dark black/yellow theme, usable one-handed in the morning.

TIER 2 (only after I approve Tier 1)
- Live GPS run tracking with background tracking, distance, pace, run/walk interval timer with beep or voice cues, route map
- Progress screens: weekly distance chart, long-run trend, pull-up/push-up max, 5k test vs 20:00 goal line
- Training paces and half-marathon estimate calculated from the 5k test (Part 4)
- Rest timer for strength sessions, local reminders for the morning session

TIER 3 (later)
- Auto-adjust plan after missed weeks, Strava or watch sync, cloud backup

RULES
- Prefer simple, readable code. No unnecessary packages.
- Write unit tests for the plan loader, swap rules, long-run cap check and the export summary generator.
- flutter analyze must pass clean.
- After Tier 1, give me exact steps to run it on my Android phone over USB (flutter run) and to build an APK.
- If anything in the spec is ambiguous, ask before guessing.
```

---

## Sources and evidence notes

- Single-run distance spikes (more than about 10% above the longest run in the previous 30 days) were linked to higher overuse-injury risk, while weekly mileage changes predicted little: Marathon Handbook summary of the British Journal of Sports Medicine cohort study of about 5,200 runners, https://marathonhandbook.com/the-10-rule-new-study-suggests-weve-been-doing-it-wrong-this-whole-time/
- A separate study of 874 runners found no overall injury difference between weekly increases under 10%, 10-30% and over 30%, but more distance-related injuries above 30%: https://runnersworldonline.com.au/common-injuries-quick-mileage-increases/
- Hal Higdon's Novice 1 half-marathon plan is a 12-week program for beginners: https://trainerday.com/hu/events/us/half-marathon-training-program-af301461 and https://us.humankinetics.com/blogs/excerpt/novice-training-programs
- Strength training, plyometrics and combined methods may improve running economy; plyometrics helped at speeds up to about 12 km/h (Sports Medicine 2024 meta-analysis): https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11052887/
- Low-to-high intensity resistance plus plyometrics, 2-3 times per week for 8-12 weeks, was effective in trained runners (J Strength Cond Res 2016 meta-analysis): https://pubmed.ncbi.nlm.nih.gov/26694507/
- Taper: a meta-analysis of 27 studies found the best results with a 2-week taper that cut volume exponentially by 41-60%: https://pubmed.ncbi.nlm.nih.gov/17762369/. A 2023 meta-analysis in endurance athletes supported cutting volume by 41-60% while keeping intensity and frequency: https://pmc.ncbi.nlm.nih.gov/articles/PMC10171681/
- Run/walk: 42 recreational marathoners with a 1-minute walk every 1.5 miles finished in about the same time as continuous runners (the 7-minute gap was not statistically significant) with less muscle pain and exhaustion: https://livescience.com/49455-marathon-walk-time.html. Counterpoint: a treadmill study found alternating run and walk at fixed paces cost about 6% more energy: https://ideas.repec.org/a/taf/rpanxx/v21y2021i1p170-179.html
- Intensity mix: a 2024 meta-analysis found polarized training (mostly easy, a little hard) beat other distributions for VO2peak only, mainly in programs under 12 weeks, with no proven advantage for other measures: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11329428/. The plan is mostly easy running with short hard efforts either way.
- Hydration: a 2015 international consensus statement recommends drinking when thirsty to avoid exercise-associated hyponatremia: https://www.sciencedaily.com/releases/2015/06/150629100926.htm. Its evidence grade is low quality and a sports-science writer notes it can fail when sweat rates are high and water is scarce: https://runnersworldonline.com.au/how-to-avoid-overdrinking/
- Sleep and injury: adolescent athletes sleeping under 8 hours had higher injury risk (https://cm.healio.com/news/orthopedics/20121025/milewski_10_3928_1081_597x_20121001_23_909304); in collegiate basketball players, more sleep was independently linked with fewer in-season injuries, but adult evidence is mixed (https://journals.sagepub.com/doi/10.1177/2325967120964481). The 6-hour readiness threshold is my judgment.
- Race-time prediction: the Riegel formula was well calibrated up to the half marathon in a large recreational-runner survey: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5000509/. It assumes proper training for the distance and tends to underpredict race time for less experienced runners: https://marathonhandbook.com/race-time-calculator/
- Volume and long runs: in a Dutch cohort of half-marathoners, higher weekly volume (over 32 km) and a longest run over 21 km were linked to faster finishes without more injuries: https://repub.eur.nl/pub/127621. Hal Higdon's novice half plans peak at 10-12 miles: https://lauranorrisrunning.com/how-far-should-you-run-before-a-half-marathon-or-marathon/. In first-time marathoners, longer training runs were linked to fewer race-day injuries and 4 or more runs per week to more injuries: https://vivo.weill.cornell.edu/display/pubid33750264
- Layoff: fitness starts dropping after about 2-3 weeks off, but most of the loss levels off and much is regained faster than it was first built (mixed evidence, mostly from other populations): https://runnersconnect.net/how-long-does-it-take-to-lose-your-running-fitness/
- Rate of weight loss: in elite athletes with strength training, losing about 0.7% of body weight per week preserved or added lean mass, while 1.4% per week did not (Garthe 2010, summarized at https://www.ironmanmagazine.com/?p=15378). A 0.5-1% per week guideline is also given at https://blogs.oregonstate.edu/wander/?p=103 (secondary sources).
- Protein: the ISSN position stand says 1.4-2.0 g/kg/day is sufficient for most exercising people and that 2.3-3.1 g/kg may help lean, resistance-trained people retain muscle in a deficit: https://pmc.ncbi.nlm.nih.gov/articles/PMC5477153
- Spot reduction: a meta-analysis of 37 comparisons found localized training had no effect on local fat: https://investigadores.anid.cl/es/public_search/work?id=663280
- Posture: a 2024 meta-analysis found strengthening, stretching and shoulder exercises improved forward head posture, rounded shoulders and thoracic kyphosis angle (https://pmc.ncbi.nlm.nih.gov/articles/PMC10832142). A 2021 meta-analysis found low-to-moderate-quality evidence that structured exercise programs of 3 months or less reduce hyperkyphosis (https://pubmed.ncbi.nlm.nih.gov/34375856/). Evidence quality is modest.
- Under-fueling: in a large Boston Marathon survey, runners with low-energy-availability indicators performed worse and needed medical help more often: https://runnersworldonline.com.au/what-to-know-about-low-energy-availability-and-how-under-fueling-affects-performance/
- My own judgment, not from a source: the deficit size (10-15%), the finals and race-week maintenance advice, the posture routine selection, the exact distances and weeks, the 115% warning threshold, pace offsets from the 5k test, the 8'/1' run/walk starting pattern, the 5-15% race-estimate adjustment, and the ranges quoted. No plan is injury-proof or guaranteed; treat all of it as a starting point and adjust with the weekly export.