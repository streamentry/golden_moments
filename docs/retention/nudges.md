# Nudges: the words a reminder says

Status: **proposal, written 2026-11-28. Nothing here is built.** The 50 English
lines are the source. The other ten languages were written by a model in one
pass, with the culture swapped where a literal line would sound odd. No native
speaker has read them. Treat them as unreviewed, the same as the app's other
machine-made text.

A nudge here is one line of text. The app picks it on the device, by fixed
rules, for a reminder a helper already turned on, or for the hint under
Today's activity on Home. "Auto" means the app chooses the words. It does not
mean the app decides to send something nobody asked for. No server, no AI in
the app, no new data, no new permission.

## What this can and cannot do

Words do not create a habit. A good first session does. The reminder only
reaches people who turned it on, and today that is iPhone and iPad only. So
better lines protect the people who already opted in. They do little for
someone who left after one try.

What better lines can do:

- Keep a reminder switched on. A stale or pushy line gets the reminder turned
  off, or notifications blocked in Settings, and then the channel is gone for
  good. Losing it costs more than any single tap is worth.
- Make the next visit feel small. "One picture, two minutes" is easier to say
  yes to than "time to play".
- Be worth reading even when nobody opens the app. A question to ask each
  other at the table is a small gift. People keep gifts switched on.

Strongest case against this work: [the plan](../plan/README.md) says families
must come back **without** reminders, and [the reuse pilot](../strategy/reuse-pilot.md)
treats a reminder as something that spoils its measure. If people do not come
back unprompted, nicer wording hides the problem for a few weeks and fixes
nothing. Do not read a lift from reminders as proof the activity is good.

## Is 50 the right number?

About right, but the total is the wrong thing to count. What matters is how
many lines **one device** can see.

- A helper picks one time of day. A morning household never sees an afternoon
  or evening line. Split 50 evenly over three times of day and each household
  gets 17, and a daily user meets repeats within three weeks.
- So most lines here work at any time. A household at any chosen time always
  has **26** to draw from (T4–T6, all Q, four for its time of day, all S, all
  K). More join on some days: three on Daily moment days, up to three on
  weekends and Mondays, four once the family has added photos.
- The current planner sends at most 14 daily notes and then about four weekly
  ones before it stops. With 26 or more lines and the no-repeat rule below, no
  line comes back inside three weeks.
- Fewer than about 20 per household repeats too soon. Many more than 50 adds
  review cost in every language without anything a user can notice. 50 lines
  across 118 app languages is already 5,900 strings to check.

## Where a line shows

| Place | Who sees it | Needs |
| --- | --- | --- |
| Body of the reminder notification | Households that turned the reminder on (iOS only today) | Nothing new. The title keeps today's pattern, "This morning: Daily moment" |
| Hint under Today's activity on Home | Everyone, on every platform, no permission | A small change to Home. Likely the bigger effect, because it reaches people who never turn a reminder on |

Tapping a notification already opens the day's activity. Keep that: one tap
from the lock screen to the first picture.

## What 20 years of shipping games says, and what we keep

Most retention craft is about when and how often, not about clever words.
These are judgments from practice, not measured results for this app.

1. **Timing beats copy.** The helper chose the hour. Never move it, never add
   a second note in a day, never send on a day the app was opened. Already
   true in `reminder_plan.dart`. Keep it.
2. **Slow down, then stop.** Daily for 14 days, weekly to day 42, then silence.
   Already true. The last note says it is the last (L1, L2), so silence reads
   as a promise kept and not as a bug.
3. **Say something real.** "Three pictures are ready", followed by their
   names, beats "Come back and play". A line that names today's actual
   pictures is the strongest kind (T1–T6).
4. **Make the ask tiny.** One picture. Two minutes. No need to finish (S1–S5).
5. **Give leave to skip.** "Not today is fine too" sounds like the wrong
   thing to send. It is the line that keeps the reminder on (K1–K4).
6. **Never repeat soon.** A line seen twice in a week reads as a machine.
7. **Each line must be true when it arrives.** If the app cannot be sure the
   named picture is the first one shown, that line is not eligible that day.

What games do that this app will not: streaks, "we miss you", countdowns,
rewards for coming back, an unfinished board used as bait, anything sent
without the helper asking. See *Lines we will not write* below.

## Rules for every line

These follow [DESIGN.md](../../DESIGN.md) (Reminders, Voice) and the safety
rules in [AGENTS.md](../../AGENTS.md).

- **Two readers.** The lock screen may be read by the helper or by the person
  the app is for. Every line must be kind to both. No "your loved one", no
  "them", no talk about one person over the other's head.
- **A lock screen is public.** Visitors see it. No word about memory, illness,
  care or age. The app shows as "Golden Moments" and the line says "pictures".
- **Ask what someone likes, never what they recall.** "Rain or fresh bread?"
  has no wrong answer. "What was your first job?" is a test. All ten Q lines
  are about taste, in the present tense.
- **No count, no gap, no guilt.** Never days, never "it has been a while",
  never "waiting for you", never feelings the app does not have.
- **No promise.** Nothing calms, helps, trains or keeps anything. A line may
  say what is there. It may not say what it will do for someone.
- **Calm shape.** No exclamation marks, no emoji, no capitals for effect. The
  only questions are ones for the two people to ask each other.
- **No weather, season or holiday.** The app does not know the hemisphere or
  the place, and holidays are hard days in many of these homes.
- **Nothing from the photos.** The app may know that own photos exist. It
  never puts a name, a face, a date or a file name in a line.
- **Short.** English at most 100 characters; other languages at most 140;
  Chinese, Japanese and Korean at most 70. A lock screen cuts the rest.
- **Slots go last, after a colon.** `{pictures}` and `{picture}` are dropped
  in as plain names. After a colon they need no case ending or article, so
  the same pattern holds in German, Vietnamese and Japanese alike.

## How the app picks a line

All on the device, with no network and no log.

1. **Who is eligible.** Use the "When it may show" column. A line with a slot
   is eligible only when the app can fill it truthfully.
2. **Fixed places first.** The last planned note is L1 or L2, taking turns.
   Weekly notes after day 14 are R1, R2, R3 in turn.
3. **Then the rest, shuffled.** Shuffle the eligible lines once with a random
   number saved on the device at first use, and walk the list. Two households
   then see different orders, and nobody can tell the date from the line.
4. **No repeat inside 21 days**, and never two lines from the same letter
   group back to back. K at most once in seven notes.
5. **A line for the day wins a tie.** If a T, W or P line is eligible today,
   use it for at most one note in three, so plain days do not vanish.
6. **Whole batch at once.** The planner already writes up to 18 notes each
   time the app opens. Assign lines across that batch in one go, so the
   pending notes never hold the same line twice. iOS keeps at most 64 pending
   local notifications; 18 is well inside that.

State this adds: one saved number for the shuffle and the IDs of recent
lines. Both stay in app preferences. Neither says anything about a person.

## Lines we will not write

| Pattern | Why not |
| --- | --- |
| "You have played 5 days in a row" | A streak. Banned by DESIGN.md, and losing one hurts |
| "We miss you" / "It has been a while" | Guilt, and the app has no feelings to report |
| "Your board is half done" | Uses an unfinished thing as bait. Gentle mode has no forced completion |
| "Only today" / "Last chance" | False urgency. Nothing here runs out |
| "Good for the mind" and the like | A health claim. Not true to say, and not allowed |
| "Do you remember…?" | Forced recall |
| A line with a name from a photo | Photo content never leaves the photo screen |
| Notes delivered quietly without asking (iOS provisional permission) | It would work and would raise reach. It breaks "off until chosen" in DESIGN.md. A maintainer decision, not a copy decision |

## How to know if it worked

Be honest about what can be seen. The app has no analytics, and that stays.

- App Store Connect shows Day 1, Day 7 and Day 28 for devices that share
  data with Apple, per period, not per line. See
  [measurement](../plan/measurement.md).
- At about 10 installs a day, comparing two wordings is not possible. To see
  Day 7 move from 10% to 15% with the usual 80% power needs about 680 new
  devices in each group (the 10% is an assumed baseline, not a measured one).
  That is months per group, with seasons changing underneath.
- So no line here can be shown to "win". Do not claim it.

Cheapest real test, before any code: print 12 lines (two from each of T, Q,
S, K, R, L), show them to five helpers in the reuse pilot, and ask one
question: "Which of these would make you turn the reminder off?" Cut every
line two people point at. Ask a native speaker the same for each language
before that language ships.

Stop if: helpers say the question lines feel like homework, if people report
turning the reminder off after the change, or if deletions in App Store
Connect rise in the weeks after release.

## Before this ships

1. Maintainer approves the idea. [The plan](../plan/README.md) and
   [the detail](../plan/detail.md) both say "never streaks or nudges". These
   lines live inside the opt-in reminder and on Home, so they may fit the
   intent, but the wording there and in DESIGN.md › Reminders has to be
   changed on purpose, not by this file.
2. Add the lines to `lib/l10n/arb/app_en.arb` with translator notes, then to
   every app language through the normal pipeline, marked unreviewed.
3. Replace the two-option pick in `reminder_plan.dart` with the rules above,
   with tests for: no repeat in 21 days, truthful slots, K spacing, L last.
4. Home hint, on all platforms.
5. Try on a real iPhone: lock screen length at 100% and 200% text, VoiceOver
   reading, tap opens the named picture.

Not done by this file: no code, no ARB strings, no native review, no device
check. The reminder is still iOS only.

## The 50 lines

Letter groups: **T** today's pictures, **Q** a question to share, **M**
morning, **N** afternoon, **V** evening, **W** day of the week, **P** own
photos, **S** small ask, **K** leave to skip, **R** after a quiet spell,
**L** last note. `{pictures}` is the day's three picture names joined with
the language's list separator. `{picture}` is the name of the first picture
the activity will show.

Food and drink were swapped, not translated, where it mattered: fresh bread
became freshly cooked rice in Japanese and Korean, and coffee leads tea in
Spanish, Portuguese, German and Italian. Sunday and Monday lines assume a
Monday-to-Friday week; use different days where the week differs.

### English (source)

| ID | When it may show | Line |
| --- | --- | --- |
| T1 | Daily moment day | Three pictures are ready: {pictures}. |
| T2 | Daily moment day | Today's three: {pictures}. One at a time, no hurry. |
| T3 | Daily moment day | On the table today: {pictures}. |
| T4 | Any day | One picture to start with: {picture}. |
| T5 | Any day | Today's first picture: {picture}. See where the talk goes. |
| T6 | Any day | Something to look at together: {picture}. |
| Q1 | Any day | A question to share: the smell of rain, or the smell of fresh bread? |
| Q2 | Any day | A question to share: is the sea better to look at, or to swim in? |
| Q3 | Any day | A question to share: which is the nicest time of day? |
| Q4 | Any day | A question to share: tea or coffee, and how do you take it? |
| Q5 | Any day | A question to share: which song is worth hearing twice? |
| Q6 | Any day | A question to share: a dog, a cat, or a quiet house? |
| Q7 | Any day | A question to share: what makes a kitchen smell like home? |
| Q8 | Any day | A question to share: which flower would you put on the table? |
| Q9 | Any day | A question to share: a walk in the hills, or a seat by the water? |
| Q10 | Any day | A question to share: what is the best thing to eat with your hands? |
| M1 | Chosen time before noon | The day is still quiet. A few pictures before it gets busy. |
| M2 | Chosen time before noon | A cup of something warm and a few pictures, one at a time. |
| M3 | Chosen time before noon | A slow start is a good start. The pictures are here when you are. |
| M4 | Chosen time before noon | Before the day fills up: one picture, one chat. |
| N1 | Chosen time noon to 5 pm | A pause in the afternoon. A few pictures, nothing to get right. |
| N2 | Chosen time noon to 5 pm | The afternoon can be long. A few pictures give you something to talk about. |
| N3 | Chosen time noon to 5 pm | Sit down for a moment. The pictures will do the talking. |
| N4 | Chosen time noon to 5 pm | Something easy for the afternoon: pick a picture you both like. |
| V1 | Chosen time after 5 pm | The day is winding down. A few calm pictures to share. |
| V2 | Chosen time after 5 pm | A quiet end to the day: some pictures, at your own pace. |
| V3 | Chosen time after 5 pm | Nothing to finish this evening. Just a few pictures to look at. |
| V4 | Chosen time after 5 pm | Lights low, pictures large. An unhurried few minutes together. |
| W1 | Saturday or Sunday | If family is visiting today, the pictures are something to do together. |
| W2 | Saturday or Sunday | Children can join in too. Big pictures, easy turns. |
| W3 | Sunday | A slow Sunday is a good day for pictures. |
| W4 | Monday | A new week. Start it with one picture and a chat. |
| P1 | Two or more own photos chosen | Your own photos are in the game, just as you chose them. |
| P2 | Two or more own photos chosen | The family photos are where you left them. Open them when it suits you. |
| P3 | Two or more own photos chosen | Today, your photos instead of ours. |
| P4 | Two or more own photos chosen | A few of your own photos, large and unhurried. |
| S1 | Any day | Two minutes is enough. One picture, one chat. |
| S2 | Any day | No need to play a whole game. One pair is a fine visit. |
| S3 | Any day | Just look. Nobody has to tap anything. |
| S4 | Any day | Short is fine. Stop after the first picture if you like. |
| S5 | Any day | There is nothing to get right, and no clock. |
| K1 | Any day, at most one in seven notes | Not today is fine too. The pictures keep. |
| K2 | Any day, at most one in seven notes | Busy day? Leave this one. Nothing is counted here. |
| K3 | Any day, at most one in seven notes | If now is a bad time, it is a bad time. The pictures will wait. |
| K4 | Any day, at most one in seven notes | You are doing plenty already. This is only here if it helps. |
| R1 | Weekly phase only (app not opened for over 14 days) | Everything is as you left it. Nothing to catch up on. |
| R2 | Weekly phase only (app not opened for over 14 days) | No news here, which is the point. The same calm pictures. |
| R3 | Weekly phase only (app not opened for over 14 days) | Still here, still simple. One picture whenever it suits you. |
| L1 | The last note before reminders stop | This is the last note for now. Open the app any time and they start again. |
| L2 | The last note before reminders stop | The notes stop here so they never pile up. The pictures stay. |

<!-- cspell:disable -->

### Spanish (es, usted, Latin America first)

| ID | Line |
| --- | --- |
| T1 | Hay tres imágenes listas: {pictures}. |
| T2 | Las tres de hoy: {pictures}. Una por una, sin prisa. |
| T3 | Hoy sobre la mesa: {pictures}. |
| T4 | Una imagen para empezar: {picture}. |
| T5 | La primera imagen de hoy: {picture}. A ver adónde lleva la conversación. |
| T6 | Algo para mirar juntos: {picture}. |
| Q1 | Una pregunta para compartir: ¿el olor a lluvia o el olor a pan recién hecho? |
| Q2 | Una pregunta para compartir: el mar, ¿es mejor para mirarlo o para meterse? |
| Q3 | Una pregunta para compartir: ¿cuál es la mejor hora del día? |
| Q4 | Una pregunta para compartir: ¿café o té, y cómo le gusta? |
| Q5 | Una pregunta para compartir: ¿qué canción merece escucharse dos veces? |
| Q6 | Una pregunta para compartir: ¿un perro, un gato o una casa tranquila? |
| Q7 | Una pregunta para compartir: ¿qué hace que una cocina huela a hogar? |
| Q8 | Una pregunta para compartir: ¿qué flor pondría en la mesa? |
| Q9 | Una pregunta para compartir: ¿un paseo por el cerro o un asiento junto al agua? |
| Q10 | Una pregunta para compartir: ¿qué es lo más rico que se come con las manos? |
| M1 | El día todavía está tranquilo. Unas imágenes antes de que empiece el ajetreo. |
| M2 | Una taza de algo caliente y unas imágenes, una por una. |
| M3 | Empezar despacio es empezar bien. Las imágenes están aquí cuando usted quiera. |
| M4 | Antes de que el día se llene: una imagen, una charla. |
| N1 | Una pausa en la tarde. Unas imágenes, sin nada que acertar. |
| N2 | La tarde puede hacerse larga. Con unas imágenes hay de qué conversar. |
| N3 | Siéntese un momento. Las imágenes ponen la conversación. |
| N4 | Algo fácil para la tarde: elija una imagen que les guste a los dos. |
| V1 | El día va bajando el ritmo. Unas imágenes tranquilas para compartir. |
| V2 | Un final de día sereno: unas imágenes, a su ritmo. |
| V3 | Esta noche no hay nada que terminar. Solo unas imágenes para mirar. |
| V4 | Luz suave, imágenes grandes. Unos minutos juntos, sin prisa. |
| W1 | Si hoy viene la familia, las imágenes son algo para hacer juntos. |
| W2 | Los niños también pueden participar. Imágenes grandes, turnos fáciles. |
| W3 | Un domingo sin prisa es buen día para mirar imágenes. |
| W4 | Semana nueva. Empiécela con una imagen y una charla. |
| P1 | Sus propias fotos están en el juego, tal como las eligió. |
| P2 | Las fotos de la familia siguen donde las dejó. Ábralas cuando le venga bien. |
| P3 | Hoy, sus fotos en lugar de las nuestras. |
| P4 | Unas cuantas fotos suyas, grandes y sin prisa. |
| S1 | Dos minutos bastan. Una imagen, una charla. |
| S2 | No hace falta jugar una partida entera. Con una pareja ya es una buena visita. |
| S3 | Solo mirar. Nadie tiene que tocar nada. |
| S4 | Corto está bien. Puede parar después de la primera imagen. |
| S5 | No hay nada que acertar, ni reloj. |
| K1 | Hoy no también está bien. Las imágenes no se van. |
| K2 | ¿Día ocupado? Deje pasar este aviso. Aquí no se cuenta nada. |
| K3 | Si ahora no es buen momento, no lo es. Las imágenes esperan. |
| K4 | Usted ya hace bastante. Esto solo está aquí por si ayuda. |
| R1 | Todo está como lo dejó. No hay nada con qué ponerse al día. |
| R2 | Aquí no hay novedades, y de eso se trata. Las mismas imágenes tranquilas. |
| R3 | Seguimos aquí, igual de sencillo. Una imagen cuando le venga bien. |
| L1 | Este es el último aviso por ahora. Abra la app cuando quiera y vuelven a empezar. |
| L2 | Los avisos terminan aquí para que no se acumulen. Las imágenes se quedan. |

### Vietnamese (vi)

| ID | Line |
| --- | --- |
| T1 | Ba hình đã sẵn sàng: {pictures}. |
| T2 | Ba hình hôm nay: {pictures}. Xem từng hình một, không vội. |
| T3 | Hôm nay có sẵn: {pictures}. |
| T4 | Một hình để bắt đầu: {picture}. |
| T5 | Hình đầu tiên hôm nay: {picture}. Rồi xem câu chuyện đi về đâu. |
| T6 | Một hình để cùng ngắm: {picture}. |
| Q1 | Một câu để hỏi nhau: mùi mưa hay mùi bánh mì mới ra lò? |
| Q2 | Một câu để hỏi nhau: biển thì ngắm thích hơn hay tắm thích hơn? |
| Q3 | Một câu để hỏi nhau: lúc nào trong ngày là dễ chịu nhất? |
| Q4 | Một câu để hỏi nhau: trà hay cà phê, và uống kiểu nào? |
| Q5 | Một câu để hỏi nhau: bài hát nào đáng nghe lại lần nữa? |
| Q6 | Một câu để hỏi nhau: nuôi chó, nuôi mèo, hay một căn nhà yên tĩnh? |
| Q7 | Một câu để hỏi nhau: mùi gì trong bếp làm mình thấy như ở nhà? |
| Q8 | Một câu để hỏi nhau: nếu cắm hoa trên bàn thì chọn hoa gì? |
| Q9 | Một câu để hỏi nhau: đi dạo trên đồi hay ngồi bên bờ nước? |
| Q10 | Một câu để hỏi nhau: món gì ăn bằng tay là ngon nhất? |
| M1 | Buổi sáng còn yên. Xem vài hình trước khi ngày bận lên. |
| M2 | Một ly gì đó ấm và vài hình, xem từng hình một. |
| M3 | Bắt đầu chậm cũng là bắt đầu tốt. Hình vẫn ở đây khi bạn sẵn sàng. |
| M4 | Trước khi ngày kín việc: một hình, một câu chuyện. |
| N1 | Nghỉ một chút buổi chiều. Vài hình thôi, không có gì phải làm đúng. |
| N2 | Buổi chiều đôi khi dài. Có vài hình là có chuyện để nói. |
| N3 | Ngồi xuống một lát. Để mấy tấm hình gợi chuyện. |
| N4 | Một việc nhẹ cho buổi chiều: chọn một hình cả hai cùng thích. |
| V1 | Ngày đang chậm lại. Vài hình nhẹ nhàng để cùng xem. |
| V2 | Khép lại một ngày thật yên: vài hình, theo nhịp của bạn. |
| V3 | Tối nay không có gì phải làm xong. Chỉ là vài hình để ngắm. |
| V4 | Đèn dịu, hình to. Vài phút bên nhau, không vội. |
| W1 | Nếu hôm nay con cháu ghé thăm, mấy tấm hình là việc cả nhà cùng làm được. |
| W2 | Trẻ con cũng chơi được. Hình to, lượt chơi dễ. |
| W3 | Một Chủ nhật thong thả rất hợp để xem hình. |
| W4 | Tuần mới. Bắt đầu bằng một hình và một câu chuyện. |
| P1 | Ảnh của nhà bạn đã ở trong trò chơi, đúng như bạn đã chọn. |
| P2 | Ảnh gia đình vẫn ở chỗ cũ. Mở ra lúc nào thuận tiện. |
| P3 | Hôm nay xem ảnh nhà mình, thay cho hình có sẵn. |
| P4 | Vài tấm ảnh của nhà bạn, to và thong thả. |
| S1 | Hai phút là đủ. Một hình, một câu chuyện. |
| S2 | Không cần chơi hết ván. Ghép được một cặp cũng là vui rồi. |
| S3 | Chỉ cần ngắm. Không ai phải chạm vào gì cả. |
| S4 | Ngắn cũng được. Xem xong hình đầu tiên rồi dừng cũng không sao. |
| S5 | Không có gì phải làm đúng, và không có đồng hồ. |
| K1 | Hôm nay không xem cũng không sao. Hình vẫn còn đó. |
| K2 | Hôm nay bận à? Cứ bỏ qua lời nhắc này. Ở đây không đếm gì cả. |
| K3 | Nếu lúc này chưa tiện thì thôi. Hình sẽ đợi. |
| K4 | Bạn đã làm nhiều rồi. Cái này chỉ ở đây khi nó giúp được. |
| R1 | Mọi thứ vẫn như lúc bạn rời đi. Không có gì phải làm bù. |
| R2 | Ở đây không có gì mới, và vậy mới đúng ý. Vẫn những hình yên ả đó. |
| R3 | Vẫn ở đây, vẫn đơn giản. Một hình, lúc nào thuận tiện. |
| L1 | Đây là lời nhắc cuối trong lúc này. Mở ứng dụng lúc nào cũng được, lời nhắc sẽ bắt đầu lại. |
| L2 | Lời nhắc dừng ở đây để không dồn lại. Hình thì vẫn còn. |

### Japanese (ja)

| ID | Line |
| --- | --- |
| T1 | 3枚の絵が用意できました：{pictures}。 |
| T2 | 今日の3枚：{pictures}。1枚ずつ、ゆっくりどうぞ。 |
| T3 | 今日はこちらです：{pictures}。 |
| T4 | 最初の1枚：{picture}。 |
| T5 | 今日の最初の絵：{picture}。話がどこへ広がるか、見てみましょう。 |
| T6 | いっしょに眺める1枚：{picture}。 |
| Q1 | 今日のひとこと：雨の匂いと、ご飯の炊ける匂い、どちらが好きですか。 |
| Q2 | 今日のひとこと：海は、眺めるのと入るのと、どちらがいいですか。 |
| Q3 | 今日のひとこと：一日のうちで、いちばん好きな時間はいつですか。 |
| Q4 | 今日のひとこと：お茶とコーヒー、どちらにしますか。どんなふうに飲みますか。 |
| Q5 | 今日のひとこと：もう一度聴きたくなる歌はどれですか。 |
| Q6 | 今日のひとこと：犬、猫、それとも静かな家。どれがいいですか。 |
| Q7 | 今日のひとこと：台所のどんな匂いが「わが家」らしいですか。 |
| Q8 | 今日のひとこと：食卓に飾るなら、どの花にしますか。 |
| Q9 | 今日のひとこと：山道の散歩と、水辺のベンチ、どちらがいいですか。 |
| Q10 | 今日のひとこと：手で食べるものの中で、いちばんおいしいのは何ですか。 |
| M1 | 朝はまだ静かです。忙しくなる前に、絵を何枚か。 |
| M2 | 温かい飲みものと絵を何枚か。1枚ずつどうぞ。 |
| M3 | ゆっくり始める朝もいいものです。絵はいつでもここにあります。 |
| M4 | 一日が慌ただしくなる前に。絵を1枚、おしゃべりをひとつ。 |
| N1 | 午後のひと休みに。絵を何枚か。正解はありません。 |
| N2 | 午後は長く感じることもあります。絵が何枚かあれば、話のきっかけになります。 |
| N3 | 少し腰を下ろしませんか。話のきっかけは絵にまかせましょう。 |
| N4 | 午後に気軽なことを：お二人とも好きな絵を1枚選んでみてください。 |
| V1 | 一日がゆっくり終わっていきます。穏やかな絵を何枚か、ごいっしょに。 |
| V2 | 静かな一日の終わりに。絵を何枚か、ご自分のペースで。 |
| V3 | 今夜は、やり終えることは何もありません。絵を眺めるだけです。 |
| V4 | 明かりは控えめに、絵は大きく。急がない数分間をごいっしょに。 |
| W1 | 今日ご家族が来られるなら、絵はみんなでできることのひとつです。 |
| W2 | お子さんもいっしょに楽しめます。絵は大きく、順番もかんたんです。 |
| W3 | のんびりした日曜日は、絵を眺めるのにぴったりです。 |
| W4 | 新しい週です。絵を1枚とおしゃべりから始めませんか。 |
| P1 | ご自分の写真が、選んだとおりにゲームに入っています。 |
| P2 | ご家族の写真は、そのままの場所にあります。ご都合のよいときにどうぞ。 |
| P3 | 今日は、こちらの絵のかわりにご自分の写真を。 |
| P4 | ご自分の写真を何枚か。大きく、ゆっくりと。 |
| S1 | 2分で十分です。絵を1枚、おしゃべりをひとつ。 |
| S2 | 最後まで遊ばなくても大丈夫です。1組そろえば、それで十分です。 |
| S3 | 眺めるだけでいいのです。何も押さなくてかまいません。 |
| S4 | 短くてかまいません。最初の1枚でやめても大丈夫です。 |
| S5 | 正解も、時計もありません。 |
| K1 | 今日はお休みでもかまいません。絵はなくなりません。 |
| K2 | お忙しい日ですか。今回は見送ってください。ここでは何も数えていません。 |
| K3 | 今がよくないときなら、それでいいのです。絵は待っています。 |
| K4 | もう十分にやっておられます。役に立つときだけ、どうぞ。 |
| R1 | すべて前のままです。取り戻すものは何もありません。 |
| R2 | ここは何も変わっていません。それがいいところです。いつもの穏やかな絵です。 |
| R3 | 変わらずここに、変わらずかんたんに。ご都合のよいときに絵を1枚。 |
| L1 | お知らせは、いったんこれで最後です。アプリを開けば、いつでもまた始まります。 |
| L2 | たまらないように、お知らせはここで止まります。絵はそのまま残ります。 |

### Chinese, Traditional (zh-Hant, Taiwan)

| ID | Line |
| --- | --- |
| T1 | 三張圖片已準備好：{pictures}。 |
| T2 | 今天的三張：{pictures}。一張一張來，不用急。 |
| T3 | 今天擺在桌上的是：{pictures}。 |
| T4 | 先看這一張：{picture}。 |
| T5 | 今天的第一張圖片：{picture}。看看話題會聊到哪裡。 |
| T6 | 可以一起看看的：{picture}。 |
| Q1 | 一個可以聊的問題：下雨的味道，還是剛出爐麵包的味道？ |
| Q2 | 一個可以聊的問題：海，是用看的好，還是下去游比較好？ |
| Q3 | 一個可以聊的問題：一天裡哪個時候最舒服？ |
| Q4 | 一個可以聊的問題：茶還是咖啡？喜歡怎麼喝？ |
| Q5 | 一個可以聊的問題：哪首歌值得再聽一遍？ |
| Q6 | 一個可以聊的問題：養狗、養貓，還是家裡安安靜靜？ |
| Q7 | 一個可以聊的問題：廚房裡什麼味道最有家的感覺？ |
| Q8 | 一個可以聊的問題：桌上要擺花的話，會選哪一種？ |
| Q9 | 一個可以聊的問題：到山上走走，還是在水邊坐坐？ |
| Q10 | 一個可以聊的問題：用手拿著吃的東西，哪一樣最好吃？ |
| M1 | 早上還很安靜。趁還沒忙起來，看幾張圖片。 |
| M2 | 一杯熱的，幾張圖片，一張一張慢慢看。 |
| M3 | 慢慢開始也是好的開始。圖片都在，等你們方便的時候。 |
| M4 | 趁今天還沒排滿：一張圖片，聊一聊。 |
| N1 | 下午歇一會兒。幾張圖片，沒有對錯。 |
| N2 | 下午有時候很長。有幾張圖片，就有話可以聊。 |
| N3 | 坐下來一會兒吧。讓圖片來開話題。 |
| N4 | 下午做點輕鬆的事：挑一張你們都喜歡的圖片。 |
| V1 | 一天慢慢靜下來了。幾張平靜的圖片，一起看看。 |
| V2 | 安安靜靜地結束這一天：幾張圖片，照自己的步調。 |
| V3 | 今晚沒有什麼要完成的。只是看幾張圖片。 |
| V4 | 燈光柔和，圖片大大的。不趕時間的幾分鐘，一起過。 |
| W1 | 今天如果有家人來，圖片是可以一起做的事。 |
| W2 | 孩子也可以一起玩。圖片大，輪流也簡單。 |
| W3 | 悠閒的星期天，很適合看看圖片。 |
| W4 | 新的一週。從一張圖片、一段閒聊開始。 |
| P1 | 你們自己的照片已經在遊戲裡，就是當初選的那幾張。 |
| P2 | 家人的照片還在原來的地方。方便的時候再打開。 |
| P3 | 今天換成你們的照片，不用我們的圖片。 |
| P4 | 幾張自己的照片，大大的，慢慢看。 |
| S1 | 兩分鐘就夠了。一張圖片，聊一聊。 |
| S2 | 不用玩完一整局。配成一對，就很好了。 |
| S3 | 只要看就好。誰都不必點任何東西。 |
| S4 | 短短的也可以。看完第一張就停也沒關係。 |
| S5 | 沒有對錯，也沒有時鐘。 |
| K1 | 今天不看也沒關係。圖片不會跑掉。 |
| K2 | 今天很忙嗎？這次就跳過吧。這裡什麼都不計算。 |
| K3 | 現在不方便，那就不方便。圖片會等。 |
| K4 | 你已經做得很多了。這個只在幫得上忙的時候才需要。 |
| R1 | 一切都和你們離開時一樣。沒有什麼要補的。 |
| R2 | 這裡沒有新消息，這正是用意。還是那些平靜的圖片。 |
| R3 | 還在這裡，還是一樣簡單。方便的時候，看一張圖片。 |
| L1 | 這是目前最後一則提醒。隨時打開 App，提醒就會重新開始。 |
| L2 | 提醒到這裡為止，免得越積越多。圖片都還在。 |

### German (de, Sie)

| ID | Line |
| --- | --- |
| T1 | Drei Bilder sind bereit: {pictures}. |
| T2 | Die drei von heute: {pictures}. Eins nach dem anderen, ganz ohne Eile. |
| T3 | Heute liegt bereit: {pictures}. |
| T4 | Ein Bild für den Anfang: {picture}. |
| T5 | Das erste Bild heute: {picture}. Mal sehen, wohin das Gespräch führt. |
| T6 | Etwas zum gemeinsamen Anschauen: {picture}. |
| Q1 | Eine Frage zum Teilen: der Geruch von Regen oder der von frischem Brot? |
| Q2 | Eine Frage zum Teilen: das Meer lieber anschauen oder lieber hineingehen? |
| Q3 | Eine Frage zum Teilen: Welche Tageszeit ist die schönste? |
| Q4 | Eine Frage zum Teilen: Kaffee oder Tee, und wie am liebsten? |
| Q5 | Eine Frage zum Teilen: Welches Lied hört man gern ein zweites Mal? |
| Q6 | Eine Frage zum Teilen: ein Hund, eine Katze oder ein ruhiges Haus? |
| Q7 | Eine Frage zum Teilen: Welcher Duft macht eine Küche zum Zuhause? |
| Q8 | Eine Frage zum Teilen: Welche Blume käme bei Ihnen auf den Tisch? |
| Q9 | Eine Frage zum Teilen: ein Spaziergang in den Hügeln oder eine Bank am Wasser? |
| Q10 | Eine Frage zum Teilen: Was schmeckt aus der Hand am besten? |
| M1 | Der Tag ist noch ruhig. Ein paar Bilder, bevor es lebhaft wird. |
| M2 | Eine Tasse von etwas Warmem und ein paar Bilder, eins nach dem anderen. |
| M3 | Ein langsamer Anfang ist ein guter Anfang. Die Bilder sind da, wenn Sie so weit sind. |
| M4 | Bevor der Tag sich füllt: ein Bild, ein Gespräch. |
| N1 | Eine Pause am Nachmittag. Ein paar Bilder, nichts muss stimmen. |
| N2 | Der Nachmittag kann lang werden. Mit ein paar Bildern gibt es etwas zu erzählen. |
| N3 | Setzen Sie sich einen Moment. Die Bilder übernehmen das Reden. |
| N4 | Etwas Leichtes für den Nachmittag: ein Bild aussuchen, das Ihnen beiden gefällt. |
| V1 | Der Tag klingt aus. Ein paar ruhige Bilder zum Teilen. |
| V2 | Ein stiller Abschluss für den Tag: ein paar Bilder, in Ihrem Tempo. |
| V3 | Heute Abend muss nichts fertig werden. Nur ein paar Bilder zum Anschauen. |
| V4 | Licht gedämpft, Bilder groß. Ein paar Minuten zusammen, ohne Eile. |
| W1 | Falls heute Familie zu Besuch kommt: Die Bilder kann man gut zusammen anschauen. |
| W2 | Kinder können mitmachen. Große Bilder, einfache Züge. |
| W3 | Ein gemütlicher Sonntag ist ein guter Tag für Bilder. |
| W4 | Eine neue Woche. Beginnen Sie sie mit einem Bild und einem Gespräch. |
| P1 | Ihre eigenen Fotos sind im Spiel, genau so, wie Sie sie ausgewählt haben. |
| P2 | Die Familienfotos sind dort, wo Sie sie gelassen haben. Öffnen Sie sie, wann es passt. |
| P3 | Heute Ihre Fotos statt unserer Bilder. |
| P4 | Ein paar Ihrer eigenen Fotos, groß und ohne Eile. |
| S1 | Zwei Minuten reichen. Ein Bild, ein Gespräch. |
| S2 | Es muss kein ganzes Spiel sein. Ein Paar ist schon ein schöner Besuch. |
| S3 | Einfach nur schauen. Niemand muss etwas antippen. |
| S4 | Kurz ist völlig in Ordnung. Sie können nach dem ersten Bild aufhören. |
| S5 | Hier gibt es nichts falsch zu machen, und keine Uhr. |
| K1 | Heute nicht ist auch in Ordnung. Die Bilder laufen nicht weg. |
| K2 | Viel los heute? Lassen Sie diese Erinnerung einfach liegen. Hier wird nichts gezählt. |
| K3 | Wenn es gerade nicht passt, passt es nicht. Die Bilder warten. |
| K4 | Sie tun schon genug. Das hier ist nur da, falls es hilft. |
| R1 | Alles ist so, wie Sie es verlassen haben. Es gibt nichts nachzuholen. |
| R2 | Hier gibt es nichts Neues, und genau so soll es sein. Dieselben ruhigen Bilder. |
| R3 | Immer noch da, immer noch einfach. Ein Bild, wann immer es passt. |
| L1 | Das ist vorerst die letzte Erinnerung. Öffnen Sie die App jederzeit, dann beginnen sie wieder. |
| L2 | Die Erinnerungen enden hier, damit sie sich nicht stapeln. Die Bilder bleiben. |

### French (fr, vous)

| ID | Line |
| --- | --- |
| T1 | Trois images sont prêtes : {pictures}. |
| T2 | Les trois du jour : {pictures}. Une à la fois, sans se presser. |
| T3 | Aujourd'hui sur la table : {pictures}. |
| T4 | Une image pour commencer : {picture}. |
| T5 | La première image du jour : {picture}. À voir où mène la conversation. |
| T6 | Quelque chose à regarder ensemble : {picture}. |
| Q1 | Une question à partager : l'odeur de la pluie ou celle du pain chaud ? |
| Q2 | Une question à partager : la mer, plutôt la regarder ou s'y baigner ? |
| Q3 | Une question à partager : quel est le plus beau moment de la journée ? |
| Q4 | Une question à partager : thé ou café, et comment le prenez-vous ? |
| Q5 | Une question à partager : quelle chanson mérite d'être écoutée deux fois ? |
| Q6 | Une question à partager : un chien, un chat ou une maison tranquille ? |
| Q7 | Une question à partager : quelle odeur fait d'une cuisine un chez-soi ? |
| Q8 | Une question à partager : quelle fleur mettriez-vous sur la table ? |
| Q9 | Une question à partager : une promenade sur les collines ou un banc au bord de l'eau ? |
| Q10 | Une question à partager : qu'est-ce qui se mange le mieux avec les doigts ? |
| M1 | La journée est encore calme. Quelques images avant qu'elle ne s'anime. |
| M2 | Une tasse de quelque chose de chaud et quelques images, une à la fois. |
| M3 | Commencer doucement, c'est bien commencer. Les images sont là quand vous voulez. |
| M4 | Avant que la journée ne se remplisse : une image, quelques mots. |
| N1 | Une pause dans l'après-midi. Quelques images, rien à réussir. |
| N2 | L'après-midi peut sembler long. Quelques images, et il y a de quoi parler. |
| N3 | Asseyez-vous un instant. Les images feront la conversation. |
| N4 | Quelque chose de simple pour l'après-midi : choisissez une image que vous aimez tous les deux. |
| V1 | La journée ralentit. Quelques images paisibles à partager. |
| V2 | Une fin de journée tranquille : quelques images, à votre rythme. |
| V3 | Rien à terminer ce soir. Juste quelques images à regarder. |
| V4 | Lumière douce, grandes images. Quelques minutes ensemble, sans se presser. |
| W1 | Si la famille passe aujourd'hui, les images sont une chose à faire ensemble. |
| W2 | Les enfants peuvent jouer aussi. Grandes images, tours faciles. |
| W3 | Un dimanche sans hâte est un bon jour pour regarder des images. |
| W4 | Nouvelle semaine. Commencez-la par une image et quelques mots. |
| P1 | Vos propres photos sont dans le jeu, telles que vous les avez choisies. |
| P2 | Les photos de famille sont là où vous les avez laissées. Ouvrez-les quand cela vous convient. |
| P3 | Aujourd'hui, vos photos plutôt que les nôtres. |
| P4 | Quelques-unes de vos photos, en grand et sans se presser. |
| S1 | Deux minutes suffisent. Une image, quelques mots. |
| S2 | Inutile de faire toute une partie. Une seule paire, c'est déjà une belle visite. |
| S3 | Regardez, simplement. Personne n'a besoin de toucher quoi que ce soit. |
| S4 | Court, c'est très bien. Vous pouvez arrêter après la première image. |
| S5 | Il n'y a rien à réussir, et pas d'horloge. |
| K1 | Pas aujourd'hui, c'est très bien aussi. Les images ne s'en vont pas. |
| K2 | Journée chargée ? Laissez passer ce rappel. Ici, on ne compte rien. |
| K3 | Si ce n'est pas le moment, ce n'est pas le moment. Les images attendront. |
| K4 | Vous en faites déjà beaucoup. Ceci n'est là que si cela aide. |
| R1 | Tout est comme vous l'avez laissé. Rien à rattraper. |
| R2 | Rien de neuf ici, et c'est voulu. Les mêmes images paisibles. |
| R3 | Toujours là, toujours simple. Une image, quand cela vous convient. |
| L1 | C'est le dernier rappel pour l'instant. Ouvrez l'application quand vous voulez, et ils reprendront. |
| L2 | Les rappels s'arrêtent ici pour ne pas s'accumuler. Les images restent. |

### Korean (ko)

| ID | Line |
| --- | --- |
| T1 | 그림 세 장이 준비되었습니다: {pictures}. |
| T2 | 오늘의 세 장: {pictures}. 한 장씩, 천천히 보세요. |
| T3 | 오늘 준비된 그림: {pictures}. |
| T4 | 처음 볼 그림 한 장: {picture}. |
| T5 | 오늘의 첫 그림: {picture}. 이야기가 어디로 흘러가는지 보세요. |
| T6 | 함께 볼 그림: {picture}. |
| Q1 | 함께 나눌 질문: 비 냄새와 갓 지은 밥 냄새, 어느 쪽이 좋으세요? |
| Q2 | 함께 나눌 질문: 바다는 바라보는 게 좋으세요, 들어가는 게 좋으세요? |
| Q3 | 함께 나눌 질문: 하루 중 어느 때가 가장 좋으세요? |
| Q4 | 함께 나눌 질문: 차와 커피 중 무엇을, 어떻게 드세요? |
| Q5 | 함께 나눌 질문: 한 번 더 듣고 싶은 노래는 무엇인가요? |
| Q6 | 함께 나눌 질문: 강아지, 고양이, 아니면 조용한 집? |
| Q7 | 함께 나눌 질문: 부엌에서 어떤 냄새가 나면 집 같으세요? |
| Q8 | 함께 나눌 질문: 식탁에 꽃을 놓는다면 어떤 꽃이 좋을까요? |
| Q9 | 함께 나눌 질문: 산길 산책과 물가 벤치, 어느 쪽이 좋으세요? |
| Q10 | 함께 나눌 질문: 손으로 먹는 음식 중에 무엇이 가장 맛있나요? |
| M1 | 아직 조용한 아침입니다. 바빠지기 전에 그림 몇 장 보세요. |
| M2 | 따뜻한 것 한 잔과 그림 몇 장, 한 장씩 보세요. |
| M3 | 천천히 시작해도 좋은 시작입니다. 그림은 준비되실 때 여기 있습니다. |
| M4 | 하루가 바빠지기 전에: 그림 한 장, 이야기 한 자락. |
| N1 | 오후의 쉬는 시간. 그림 몇 장이면 됩니다. 맞히실 것은 없습니다. |
| N2 | 오후가 길게 느껴질 때가 있습니다. 그림 몇 장이면 나눌 이야기가 생깁니다. |
| N3 | 잠시 앉아 보세요. 이야기는 그림이 꺼내 줍니다. |
| N4 | 오후에 하기 쉬운 일: 두 분 모두 좋아하는 그림을 한 장 골라 보세요. |
| V1 | 하루가 저물어 갑니다. 차분한 그림 몇 장을 함께 보세요. |
| V2 | 조용한 하루의 마무리: 그림 몇 장을 편한 속도로. |
| V3 | 오늘 저녁에는 끝내야 할 것이 없습니다. 그림 몇 장만 보시면 됩니다. |
| V4 | 조명은 은은하게, 그림은 크게. 서두르지 않는 몇 분을 함께하세요. |
| W1 | 오늘 가족이 오신다면, 그림은 함께 하기 좋은 일입니다. |
| W2 | 아이들도 함께할 수 있습니다. 그림이 크고 차례도 쉽습니다. |
| W3 | 느긋한 일요일은 그림 보기 좋은 날입니다. |
| W4 | 새로운 한 주입니다. 그림 한 장과 이야기로 시작해 보세요. |
| P1 | 직접 고르신 사진이 그대로 게임에 들어 있습니다. |
| P2 | 가족 사진은 두신 자리에 그대로 있습니다. 편하실 때 열어 보세요. |
| P3 | 오늘은 저희 그림 대신 직접 고르신 사진으로. |
| P4 | 직접 고르신 사진 몇 장을 크게, 천천히. |
| S1 | 2분이면 충분합니다. 그림 한 장, 이야기 한 자락. |
| S2 | 한 판을 다 하지 않으셔도 됩니다. 한 쌍만 맞춰도 충분합니다. |
| S3 | 보기만 하셔도 됩니다. 아무것도 누르지 않으셔도 됩니다. |
| S4 | 짧아도 괜찮습니다. 첫 그림만 보고 멈추셔도 됩니다. |
| S5 | 맞히실 것도, 시계도 없습니다. |
| K1 | 오늘은 쉬셔도 괜찮습니다. 그림은 그대로 있습니다. |
| K2 | 바쁜 날인가요? 이번 알림은 넘기세요. 여기서는 아무것도 세지 않습니다. |
| K3 | 지금이 좋지 않은 때라면 그런 겁니다. 그림은 기다립니다. |
| K4 | 이미 충분히 하고 계십니다. 도움이 될 때만 쓰시면 됩니다. |
| R1 | 모든 것이 두신 그대로입니다. 따라잡을 것은 없습니다. |
| R2 | 여기는 달라진 것이 없습니다. 그게 좋은 점입니다. 늘 같은 차분한 그림입니다. |
| R3 | 여전히 여기에, 여전히 간단하게. 편하실 때 그림 한 장. |
| L1 | 당분간 마지막 알림입니다. 언제든 앱을 여시면 다시 시작됩니다. |
| L2 | 쌓이지 않도록 알림은 여기서 멈춥니다. 그림은 그대로 있습니다. |

### Chinese, Simplified (zh-Hans)

| ID | Line |
| --- | --- |
| T1 | 三张图片已准备好：{pictures}。 |
| T2 | 今天的三张：{pictures}。一张一张来，不用急。 |
| T3 | 今天摆在桌上的是：{pictures}。 |
| T4 | 先看这一张：{picture}。 |
| T5 | 今天的第一张图片：{picture}。看看话题会聊到哪里。 |
| T6 | 可以一起看看的：{picture}。 |
| Q1 | 一个可以聊的问题：下雨的味道，还是刚出炉面包的味道？ |
| Q2 | 一个可以聊的问题：大海，是看着好，还是下去游更好？ |
| Q3 | 一个可以聊的问题：一天里哪个时候最舒服？ |
| Q4 | 一个可以聊的问题：茶还是咖啡？喜欢怎么喝？ |
| Q5 | 一个可以聊的问题：哪首歌值得再听一遍？ |
| Q6 | 一个可以聊的问题：养狗、养猫，还是家里安安静静？ |
| Q7 | 一个可以聊的问题：厨房里什么味道最有家的感觉？ |
| Q8 | 一个可以聊的问题：桌上要摆花的话，会选哪一种？ |
| Q9 | 一个可以聊的问题：去山上走走，还是在水边坐坐？ |
| Q10 | 一个可以聊的问题：用手拿着吃的东西，哪一样最好吃？ |
| M1 | 早上还很安静。趁还没忙起来，看几张图片。 |
| M2 | 一杯热的，几张图片，一张一张慢慢看。 |
| M3 | 慢慢开始也是好的开始。图片都在，等你们方便的时候。 |
| M4 | 趁今天还没排满：一张图片，聊一聊。 |
| N1 | 下午歇一会儿。几张图片，没有对错。 |
| N2 | 下午有时候很长。有几张图片，就有话可聊。 |
| N3 | 坐下来一会儿吧。让图片来开个话头。 |
| N4 | 下午做点轻松的事：挑一张你们都喜欢的图片。 |
| V1 | 一天慢慢静下来了。几张平静的图片，一起看看。 |
| V2 | 安安静静地结束这一天：几张图片，按自己的节奏。 |
| V3 | 今晚没有什么要完成的。只是看几张图片。 |
| V4 | 灯光柔和，图片大大的。不赶时间的几分钟，一起过。 |
| W1 | 今天如果有家人来，图片是可以一起做的事。 |
| W2 | 孩子也可以一起玩。图片大，轮流也简单。 |
| W3 | 悠闲的星期天，很适合看看图片。 |
| W4 | 新的一周。从一张图片、一段闲聊开始。 |
| P1 | 你们自己的照片已经在游戏里，就是当初选的那几张。 |
| P2 | 家人的照片还在原来的地方。方便的时候再打开。 |
| P3 | 今天换成你们的照片，不用我们的图片。 |
| P4 | 几张自己的照片，大大的，慢慢看。 |
| S1 | 两分钟就够了。一张图片，聊一聊。 |
| S2 | 不用玩完一整局。配成一对，就很好了。 |
| S3 | 只要看就好。谁都不必点任何东西。 |
| S4 | 短短的也可以。看完第一张就停也没关系。 |
| S5 | 没有对错，也没有时钟。 |
| K1 | 今天不看也没关系。图片不会跑掉。 |
| K2 | 今天很忙吗？这次就跳过吧。这里什么都不计数。 |
| K3 | 现在不方便，那就不方便。图片会等。 |
| K4 | 你已经做得很多了。这个只在帮得上忙的时候才需要。 |
| R1 | 一切都和你们离开时一样。没有什么要补的。 |
| R2 | 这里没有新消息，这正是用意。还是那些平静的图片。 |
| R3 | 还在这里，还是一样简单。方便的时候，看一张图片。 |
| L1 | 这是目前最后一条提醒。随时打开应用，提醒就会重新开始。 |
| L2 | 提醒到这里为止，免得越积越多。图片都还在。 |

### Portuguese, Brazil (pt-BR)

| ID | Line |
| --- | --- |
| T1 | Três imagens estão prontas: {pictures}. |
| T2 | As três de hoje: {pictures}. Uma de cada vez, sem pressa. |
| T3 | Hoje na mesa: {pictures}. |
| T4 | Uma imagem para começar: {picture}. |
| T5 | A primeira imagem de hoje: {picture}. Vamos ver aonde a conversa vai. |
| T6 | Algo para olhar juntos: {picture}. |
| Q1 | Uma pergunta para dividir: cheiro de chuva ou cheiro de pão saindo do forno? |
| Q2 | Uma pergunta para dividir: o mar é melhor para olhar ou para entrar? |
| Q3 | Uma pergunta para dividir: qual é a melhor hora do dia? |
| Q4 | Uma pergunta para dividir: café ou chá, e como você gosta? |
| Q5 | Uma pergunta para dividir: que música merece ser ouvida duas vezes? |
| Q6 | Uma pergunta para dividir: um cachorro, um gato ou uma casa sossegada? |
| Q7 | Uma pergunta para dividir: que cheiro faz uma cozinha parecer um lar? |
| Q8 | Uma pergunta para dividir: que flor você colocaria na mesa? |
| Q9 | Uma pergunta para dividir: uma caminhada no morro ou um banco à beira d'água? |
| Q10 | Uma pergunta para dividir: qual é a melhor coisa de comer com as mãos? |
| M1 | O dia ainda está calmo. Algumas imagens antes que a correria comece. |
| M2 | Uma xícara de algo quente e algumas imagens, uma de cada vez. |
| M3 | Começar devagar é começar bem. As imagens estão aqui quando você quiser. |
| M4 | Antes que o dia fique cheio: uma imagem, uma conversa. |
| N1 | Uma pausa à tarde. Algumas imagens, nada para acertar. |
| N2 | A tarde às vezes é longa. Com algumas imagens, há assunto para conversar. |
| N3 | Sente-se um pouco. As imagens puxam a conversa. |
| N4 | Algo leve para a tarde: escolha uma imagem de que vocês dois gostem. |
| V1 | O dia vai desacelerando. Algumas imagens tranquilas para dividir. |
| V2 | Um fim de dia sossegado: algumas imagens, no seu ritmo. |
| V3 | Hoje à noite não há nada para terminar. Só algumas imagens para olhar. |
| V4 | Luz baixa, imagens grandes. Alguns minutos juntos, sem pressa. |
| W1 | Se a família vier hoje, as imagens são algo para fazer juntos. |
| W2 | As crianças também podem participar. Imagens grandes, jogadas fáceis. |
| W3 | Um domingo sem pressa é um bom dia para ver imagens. |
| W4 | Semana nova. Comece com uma imagem e uma conversa. |
| P1 | As suas fotos estão no jogo, do jeito que você escolheu. |
| P2 | As fotos da família estão onde você deixou. Abra quando for bom para você. |
| P3 | Hoje, as suas fotos no lugar das nossas. |
| P4 | Algumas fotos suas, grandes e sem pressa. |
| S1 | Dois minutos bastam. Uma imagem, uma conversa. |
| S2 | Não precisa jogar uma partida inteira. Um par já é uma boa visita. |
| S3 | É só olhar. Ninguém precisa tocar em nada. |
| S4 | Curto está ótimo. Pode parar depois da primeira imagem. |
| S5 | Não há nada para acertar, nem relógio. |
| K1 | Hoje não também está tudo bem. As imagens não vão embora. |
| K2 | Dia corrido? Deixe este lembrete passar. Aqui nada é contado. |
| K3 | Se agora não é uma boa hora, não é. As imagens esperam. |
| K4 | Você já faz bastante. Isto só está aqui se ajudar. |
| R1 | Está tudo como você deixou. Não há nada para pôr em dia. |
| R2 | Nenhuma novidade por aqui, e a ideia é essa. As mesmas imagens tranquilas. |
| R3 | Ainda aqui, ainda simples. Uma imagem, quando for bom para você. |
| L1 | Este é o último lembrete por enquanto. Abra o app quando quiser e eles recomeçam. |
| L2 | Os lembretes param aqui para não se acumularem. As imagens ficam. |

### Italian (it, voi)

| ID | Line |
| --- | --- |
| T1 | Tre immagini sono pronte: {pictures}. |
| T2 | Le tre di oggi: {pictures}. Una alla volta, senza fretta. |
| T3 | Oggi sul tavolo: {pictures}. |
| T4 | Un'immagine per cominciare: {picture}. |
| T5 | La prima immagine di oggi: {picture}. Vediamo dove porta la conversazione. |
| T6 | Qualcosa da guardare insieme: {picture}. |
| Q1 | Una domanda da condividere: il profumo della pioggia o quello del pane appena sfornato? |
| Q2 | Una domanda da condividere: il mare è meglio guardarlo o farci il bagno? |
| Q3 | Una domanda da condividere: qual è il momento più bello della giornata? |
| Q4 | Una domanda da condividere: caffè o tè, e come vi piace? |
| Q5 | Una domanda da condividere: quale canzone merita un secondo ascolto? |
| Q6 | Una domanda da condividere: un cane, un gatto o una casa tranquilla? |
| Q7 | Una domanda da condividere: quale profumo fa di una cucina una casa? |
| Q8 | Una domanda da condividere: quale fiore mettereste in tavola? |
| Q9 | Una domanda da condividere: una passeggiata in collina o una panchina vicino all'acqua? |
| Q10 | Una domanda da condividere: qual è la cosa più buona da mangiare con le mani? |
| M1 | La giornata è ancora tranquilla. Qualche immagine prima che si riempia. |
| M2 | Una tazza di qualcosa di caldo e qualche immagine, una alla volta. |
| M3 | Cominciare piano è cominciare bene. Le immagini sono qui quando volete. |
| M4 | Prima che la giornata si riempia: un'immagine, due chiacchiere. |
| N1 | Una pausa nel pomeriggio. Qualche immagine, niente da indovinare. |
| N2 | Il pomeriggio a volte è lungo. Con qualche immagine c'è di che parlare. |
| N3 | Sedetevi un momento. Alla conversazione pensano le immagini. |
| N4 | Qualcosa di facile per il pomeriggio: scegliete un'immagine che piace a entrambi. |
| V1 | La giornata rallenta. Qualche immagine tranquilla da condividere. |
| V2 | Una fine di giornata serena: qualche immagine, con i vostri tempi. |
| V3 | Stasera non c'è niente da finire. Solo qualche immagine da guardare. |
| V4 | Luci basse, immagini grandi. Qualche minuto insieme, senza fretta. |
| W1 | Se oggi viene la famiglia, le immagini sono qualcosa da fare insieme. |
| W2 | Anche i bambini possono partecipare. Immagini grandi, turni facili. |
| W3 | Una domenica senza fretta è un buon giorno per guardare immagini. |
| W4 | Settimana nuova. Cominciatela con un'immagine e due chiacchiere. |
| P1 | Le vostre foto sono nel gioco, proprio come le avete scelte. |
| P2 | Le foto di famiglia sono dove le avete lasciate. Apritele quando vi va. |
| P3 | Oggi le vostre foto al posto delle nostre. |
| P4 | Qualche vostra foto, in grande e senza fretta. |
| S1 | Due minuti bastano. Un'immagine, due chiacchiere. |
| S2 | Non serve fare una partita intera. Una coppia è già una bella visita. |
| S3 | Basta guardare. Nessuno deve toccare niente. |
| S4 | Breve va benissimo. Potete fermarvi dopo la prima immagine. |
| S5 | Non c'è niente da indovinare, e nessun orologio. |
| K1 | Anche oggi no va bene. Le immagini non scappano. |
| K2 | Giornata piena? Lasciate perdere questo promemoria. Qui non si conta niente. |
| K3 | Se adesso non è il momento, non è il momento. Le immagini aspettano. |
| K4 | Fate già abbastanza. Questo è qui solo se aiuta. |
| R1 | È tutto come l'avete lasciato. Non c'è niente da recuperare. |
| R2 | Nessuna novità qui, ed è voluto. Le stesse immagini tranquille. |
| R3 | Ancora qui, ancora semplice. Un'immagine, quando vi va. |
| L1 | Questo è l'ultimo promemoria per ora. Aprite l'app quando volete e ricominciano. |
| L2 | I promemoria si fermano qui, così non si accumulano. Le immagini restano. |

<!-- cspell:enable -->
