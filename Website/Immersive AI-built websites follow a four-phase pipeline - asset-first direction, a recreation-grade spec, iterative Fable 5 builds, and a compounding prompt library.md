---
created: 2026-08-06
description: A 14:35 tutorial (surfaced via @mikenevermiss) by the motionsites designer behind 100+ AI-built animated websites, distilled into a four-phase pipeline — asset-first direction (Pinterest motif → Higgsfield hero video), a recreation-grade four-block spec (exact asset URLs / fonts / global layer structure / scroll-scrub behavior), iterative Fable 5 builds in Cursor (~10 min to first result), and a compounding flywheel where every finished page is converted back into an "exact recreation prompt." Plus his X-growth and video-pack-sales playbook.
source: https://x.com/mikenevermiss/status/2084570947252527208
author: unnamed designer (motionsites creator), amplified by @mikenevermiss (MIKE)
type: video
duration: "14:35"
tags: [website-design, web-design, immersive-websites, scroll-animation, fable-5, cursor, higgsfield, prompt-library, design-process, x-growth]
---

## Key Takeaways

- **Phase 1 — Assets first, not layout first.** The pipeline starts *before any code*: find one strong visual motif on Pinterest ("abstract 3D forms, hanging white cables, glowing gold tips"), then generate the hero **video** from it in Higgsfield — image-to-video with first-frame/last-frame prompting and physically-stated constraints ("the tops of the cables stay fixed in place, never moving; the bottom ends extend, growing longer and moving downward"). The "immersive" feel is ~80% this generated asset and ~20% CSS; the same asset-quality-upstream lesson as [[ai longform ai videos look real when the starting frame and audio are high quality]], and the video-prompting craft rhymes with [[sora 2 prompting improves video consistency when prompts read like cinematographer briefs]] and the [[nine prompts turn Claude plus Higgsfield into a product video factory|Claude + Higgsfield pipeline]] already in the vault. Host assets at stable URLs (his: CloudFront) so the spec can reference them exactly.

- **Phase 2 — The recreation-grade spec is the real IP, and it has four blocks** (read directly off his Apple Notes in the frames): **Assets** — exact URLs plus a prose description of the video content, local-mirror fallback note, and display treatment (`h-24 w-20, rounded-lg, object-cover`, alt text); **Fonts** — exact Google Fonts weights (Inter 400/500/600/900), font stacks, Tailwind `font-sans`/`font-mono` mapping, selection color, page bg `#0a0a0a`, default text white; **Global structure** — the layer sandwich: fixed `inset-0 z-0 pointer-events-none` ScrollVideo layer under a `z-10` content wrapper, fixed navbar, `min-h-screen` sections, an `aria-hidden h-[200vh]` spacer that is *"critical for scroll video length"* (the non-obvious trick — it gives the scrubbed video its scroll runway), and a padding rhythm (`px-5 sm:px-8 md:px-12`, `pt-24/pt-28` under the fixed nav); **Scroll-scrubbed video behavior** — with the performance escape hatch: convert MP4 → JPEG sequence and scrub frames "so it will not be lagging on any device."

- **Phase 3 — Build conversationally in Cursor with Fable 5, iterate with corrective specifics.** He runs Fable 5 through Cursor ("works way faster than the Claude app" — the workflow is model-strong but tool-agnostic; one frame shows a Grok 4.6 composer). Start a fresh folder, paste a style prompt keeping *only* fonts/UI tokens, describe layout in plain language ("two sections, black background, text white, very minimalistic, no other elements"), then iterate with specific corrections: "make all content full opacity," "do not add any overlay on the video, do not change any colors, keep the video full opacity," "center should be empty, some content left, some right." First result in ~10 minutes; "30 minutes to an hour" to award-quality. A font swap from a second style prompt ("update fonts and the design of our content — do not add any images, just fonts and colors") restyles the whole page in one turn.

- **Phase 4 — The flywheel: every finished page becomes a prompt.** The signature move (visible verbatim in the frames): ask the agent for *"the superdetailed exact prompt to recreate this page exactly as it is, including the correct asset URLs, all elements, animations, and fonts"* — and the agent emits a pixel-faithful spec ("Recreate this page pixel-faithfully… React + Tailwind. No cards, no purple, no Inter/Roboto. Black/cream editorial portfolio look."). Saved to Notes, these specs *are* his motionsites prompt library — each build compounds into a reusable, sellable template. This pattern also closes the library gap for anyone else: build a rough copy of any site you admire, then extract its recreation prompt.

- **The distribution half, and the honest critique.** Growth: post high-quality screen recordings (CleanShot/ScreenStudio), tag **one** bigger account per post (companies repost; tagging many competitors kills amplification — none will boost rivals), minimal copy + inspo credit — he grew to 66K followers in a year and gets "90% of clients" from X, the designer's edition of [[Making a launch trend on X is a four-stage system - swipe-file research, a claim-and-comment-gate hook, tiered-creator breadth, and spike conversion|the launch-trending playbook]]. Products: sell packs of generated scroll videos ($9 for 20 → $49 for 100; "10 sales/day = $14K/month" — classic creator-math, treat with salt). Caveats to keep in view: the video is a funnel for his prompt library, "Fable 5 tutorial" oversells what is really *any strong model + great specs*, and the irreducible gap is **taste** — the process is fully reproducible, but which motif/font/composition to choose is where his 100-site experience lives.

*The recreation-prompt move, live in Cursor — "give me the superdetailed exact prompt to recreate this page exactly as it is":*
![[mikenevermiss-527208-001.png]]

*The four-block spec in Apple Notes (Assets with exact URLs → Fonts → Global structure with the h-[200vh] spacer → scroll-scrub behavior), with Higgsfield on the left:*
![[mikenevermiss-527208-002.png]]

*The result: "We build quiet, deliberate interfaces for loud ideas" — generated hero video as scroll-scrubbed background:*
![[mikenevermiss-527208-003.png]]

## External Resources

- Source post: [@mikenevermiss amplifying the tutorial](https://x.com/mikenevermiss/status/2084570947252527208) (QTs his own [Everything Fable 5 article](https://x.com/mikenevermiss/status/2073278341377912944))
- Tools in the pipeline: [Higgsfield](https://higgsfield.ai/) (hero-video generation) · Cursor + Claude Fable 5 (build) · Pinterest (direction) · motionsites (his prompt library) · CleanShot / Screen Studio (recording) · Lemon Squeezy (selling packs) · MP4→JPEG-sequence converters (scroll-scrub performance)

## Original Content

> [!quote]- Source tweet (@mikenevermiss, 2026-08-04)
> this is insane 🔥
>
> this guy just uploaded a 14-minute tutorial on how to build immersive websites with Claude Fable 5.
>
> save this before you lose it.
>
> (QT of @mikenevermiss: Article: Everything Fable 5.)

> [!quote]- Full video transcript (14:35, Whisper-transcribed; tool names normalized where obvious: "Hicksfield"=Higgsfield, "motion sites"=motionsites, "Outwork"=Upwork, "lemon's quiz"=Lemon Squeezy)
> In this video, I'll share with you step-by-step process of creating this crawling animated websites. I'll share with you all of the prompts and all of the tips that I'm using to build websites like these using AI. I build more than 100 websites using AI and all of them are animated with animated videos, with interactions, with animations. As you can see, everything is in code, in text. I didn't use Figma to build these animated websites.
>
> Everything is mobile responsive, that is precious thing and great thing about AI building. We're going to be using Claude Fable 5 for this version, so you can select it here. There are two ways to actually use this option. First one is using Claude app, so you go to Claude AI and just download Claude and you'll have this on your computer or you can use what I'm using is cursor, not affiliated or sponsored with cursors. I just found that it works way faster than Claude.
>
> So let's just up to you whatever you use if you use even online options like Google AI Studio or anything like that could also work as well. So yeah, let's start by just generating our images and videos and then building the websites for the prompt. You can follow along. We're going to start with assets. So for the assets, it is abstract 3D forms hanging with white cables.
>
> So this is what you can type on Pinterest. Pinterest is actually a great way to find inspiration for your designs. So just go here and you'll see a lot of different cool designs that were built by designers. You don't have to copy exactly. You can just take inspiration from that.
>
> So once you found that, the next step in our process is to actually create videos. So for the videos, we're going to use N before and to generate that to generate that I'm going to be using Hicksfield, not affiliated or sponsored with Hicksfield. That's what I'm just using. You can use cheaper options. But after which you rate our video, we'll have a result like this for the prompt, you can type something like we look at this which prompt could work.
>
> Yeah, so something like use image to first frame and the second frame and the top of the cable stay fixed in the place never moving the bottom ends. The cable extend growing longer and move downward. Basically, you can just test and experiment with prompt if you have some reference video. Like for example, in the prompt that I'll send you, you'll have a link to the video. So you can actually use it as a reference and the simplest way to do that is just basically asking AI to create a video exactly like this.
>
> So you'll have the exact same video and with any updates or changes that you want. After you have the video, we can start building our front end or our website. So for this, I don't usually like to ask you to build a front end. I'll usually go to motion size that I add and find phone styles that I like and then I can choose recent here. I can also choose free and I'll have the ability to just find phone styles and designs that I like.
>
> So let's say we like this one. All I have to do is just copy this and then I would just go to cloud or cursor. You would want to start a new project and you would also want a new folder. So here you can just select new folder name it something like scrolling lines 3D or whatever you prefer. And here you can just paste the prompt and say something like create me a here section.
>
> I'm sure that the voice app selected. I'm using the voice so as by the way for the voice text. A lot of you have been asking not affiliated with them either, but now I can just basically talk to my computer and all it I have to take from this prompt since we're going to be building our custom UI. I just want to take the fonts, the UI elements and everything else. I can just get rid of this.
>
> Now that we have the main styles, we can explain what we wanted to build. So for this one, let's go back to our prompt, which is this one. Again, the fonts are here so we can just use this basically. Build me a simple two section website. The here section should be on the white back on the black background and the text should be white.
>
> Very minimalistic. No other elements should be on the page just that. And then under the here section, there should be another section also pretty minimalistic black background and some text on that section. Build me a and now we can choose fable 5 and make sure that everything that we need is here. So global structure, we could also copy the whole prompt to build this, but I wanted to show you the process that I would do.
>
> Let's just send that and see what it comes back with. And this is the result we received. Let's add our video here and see how it looks like. So for the video, again, take this part from the prompt, which is assets, paste it in here, just replace the link or the video with the ones that you're generated. Go back to cursor, paste it in here.
>
> And for the next part of the prompt, we're going to paste which is scroll scrubbed video background. This is important for the video to play smoothly. Or you can just convert the video to frames using website jpeg MP4 to jpeg sequence. And you'll have a sequence of images that will not be lagging on any device, etc. For the simplicity of this tutorial, use the video.
>
> And let's just send that. Let's see if there is any other details in the prompt that we would need to include here. But actually, let's send that and see what it comes back with. One more detail. Do not add any overlay on the video and do not change any colors on the page.
>
> Keep the content wide as it is and keep the video full opacity. And let's just send that and see what it comes back with. And this is the result that we received. As you can see, we have this nice scrolling animated website. Of course, we can update it.
>
> We can add more sections to it. But the biggest issue that I see right now is we make all of the content. Let's make all of the content on the page have full opacity. So we have now some pieces of text that have reduced opacity. Let's increase that to be 100% opacity.
>
> And move the content in here section to the bottom as well as add some more links to the nav bar. And in the second section, position text position the content around the center. So some on the left side, some on the right side, and the center should be empty. And just send that and see what it comes back with. Let's maybe yeah, let's use table five.
>
> And this is what we've got. It is looking much better. But I want to try one more option. So for this, I'm going to again go to motion sites. And there is new prompt that I just uploaded.
>
> I want to take like this kind of futuristic font and add to it and see how it's going to look like. So I'm just going to paste it in here. Oops, not in there. This and I'm just want to I just want to find the fonts kind of style. So let's use this fonts and we can select this, paste it out cursor.
>
> And then also we need the sizes of the phones. So have line, adding or we can see what you own seven. Yeah, so we can say some like this. Let's update fonts and the kind of design of our content on our page. Do not add any images if there are any in the prompt, just update the fonts and the colors.
>
> And that's it. And now I was just send that and see what it comes back with. And this is the result of got in less than 10 minutes. If you just spend it on it a little bit more, maybe like 30 minutes to an hour, you can create something that would reward winning quality. Now let me show you how you can actually grow on Twitter and find clients because I think Twitter is the best thing for designers to find clients, even better than Outwork or YouTube.
>
> I've been on Twitter for a year and I grew it to 66,000 followers. And it actually brings me 90% of my clients, all my customers compared to YouTube that I've been doing for four to five years. This is actually a steal and a great platform for designers to grow. Now share with you the details. I took my account to grow and what kind of post I posted and how I did that and how I started when I had zero followers because now it's pretty easy to post whatever I posted will kind of get likes.
>
> But in the beginning when I started it didn't. So yeah, let me show you how I did that. And the first step is actually to post whatever you did is in a good quality. Just record this screen of it. So let me just go to the cursor and say we have this piece of content.
>
> All I have to do is just use any recording tool like CleanShot or ScreenStudio. These are paid and for Mac. So if you're in Windows, you can find something other. So let's just select the area that I wanted to record. And now we can just click video recording.
>
> And now it might be lagging because I have two video recordings working at the same time plus a thousand applications open. So yeah, now I can just take this and go to Twitter and the way that I grew and the way that a lot of people grow and me show an example of Victor. So they just tag profiles or companies that are bigger than me. So for example, I once mentioned Gemini and Logan, someone who works on the team with that time, like 10x followers than me. I was like a 5,000 or something and he with 300,000 tagged me and it gave me a lot of the people who saw my post same base 44.
>
> Like if you just tag companies and they will repost you and another example is this dude, he also just tagged me and because my website's go viral, he's post got 200,000 views because he used some of my prompts. So just tag bigger companies and by doing that, they might comment, they might repost it and you'll get some exposure from that. But again, your post has to be a good quality. Just look at this example. It is really, really good quality.
>
> Like he took one of the prompts for motion sites, which is this one. And he basically customized it to be something great. Like I see a lot of people just taking prompt from motion sites and literally changing like font and make it way more worse than originally were and they tagging me thinking that I will repost it. Like I would never do that. The quality of the post should be something similar of this level if you want me to repost it.
>
> And it is possible. You will get clients if you post something like this. And yeah, this looks really good. It doesn't look exactly like the prompt on the website. And that's what I'm teaching you how to actually customize the stuff not to make exactly like this.
>
> But yeah. So after you do this, you can just copy this basically as an example. I'll upload this. Don't try to mention Victor, or the end then base 44, whatever Google anti-gravity 55,000 companies Google AI studio. If you do that, none of these will comment because they basically they repost it or commented.
>
> They will advertise their competitors. And by doing that, why would they do that? So basically if you tag a lot of the competitors, they don't do not want to give exposition or exposure to other companies. So just tag one person, keep very minimalistic. So the GPT is very great at design short, short sentence, then say something else like inspecredits and one person for inspecredits.
>
> And this is actually not only the post look great, but actually the composition of your text, the tweet is what matters on Twitter, looks great. And then it has higher chance of going viral. So yeah, this is it. Another way to grow your customers is to do digital products. This is the very easiest one.
>
> What you have to do is just ask cursor to basically turn this into a website where I'll be selling these kind of big ground videos and then add a like a call to action to buy pack of 20 videos like this, which are scroll based. And there would be a link to a lemon's quiz or Pinterest for people to buy it for $9. And basically if you can create 20 animated videos like these, then you can easily sell it for nine. And that if you add some more 20, then you have 40 videos, you can easily increase the price to 19. That if you have 100 videos, you can sell that pack for $49.
>
> And if just like 10 people buy it a day for 49, you'll have $490 a day. And that equals to 14,000 a month. And trust me, 10 people to buy a day, a quality pack of videos like this is very extremely easy, especially if you do and know how to do social media, you can achieve that results. And yeah, this was it for this video. Thank you for watching and I'll see you in the next one.
