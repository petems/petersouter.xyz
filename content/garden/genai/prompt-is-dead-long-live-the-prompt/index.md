---
title: "LLM + Prompting 101"
date: 2026-04-13T00:00:00+00:00
description: "Braindump notes taken from an LLM + Agentic Flow History and 101 talk I gave."
garden_topic: "GenAI"
status: "Budding"
---

I'd been putting together a talk and workshop which was a combo a brief history of LLM's, what prompt engineering looks like in 2026, and finally leads in to a practical session making a skill to solve a practical work-related usecase that they can use in the real world.

The audience was a bit of a mix, but mostly it's for folks interested in LLMs and GenAI but who hadn't necessarily followed the whole history of how we got here. I think it's important to know what makes LLM's tick, what they can and can't do natively, and a bit of a history of how we got here in the first place. Overall, the message is...

> "Prompt engineering didn't die — it became a component of something bigger".

The problem I had was... originally I'd spent so much time talking about the history of LLM's, we then jarringly jump into writing skills, without much introduction of what a skill actually is!

So, I slimmed down the "History of LLM's Plus 101 Prompt Engineering" down a bit so we could also talk about skills and some example usecases, but I put a lot of work into that initial history and wanted to do something with it some day.

So here are my core notes on that first history-less bit of the talk, which are perfect for a Garden post: They jump around a bit and don't really have a core narrative or story, so probably not ready for a Proper Blog™, but eventually someday I'll fix and maybe turn into a proper blog post

Overall, I'm proud of the work I did, but it's a bit of a brain dump currrently. Good for me trying to figure out all the various topics, but not so great for the newbies who wanted more of a 5 minute pitch of "This is what an LLM is, this is what a skill is, Now lets get cracking on a skill to help you with writing emails and checking calendar events" and suchlike...

{{< info >}}
Since this was repurposed from a slide deck, I tried to keep it's original structure a bit. So bit's in `> quote` formatting were speaker notes, everything else was the slide content for visual impact.
{{< /info >}}

## Key Thesis

> A model is only as useful as the information you give it access to.

This single idea explains why prompting matters, why context engineering emerged, and why agentic tools changed everything: They're all solving the same problem at different scales.

## LLMs History

- Language models have been around for decades
- **Word2Vec** (Google, 2013) and **GloVe** (Stanford, 2014) captured word relationships: `king − man + woman = queen`,
- But they were narrow — One model, One job

> For text generation, the main approach for several decades was Recurrent Neural Networks — RNNs. RNNs process each token of their input sequentially — one at a time — in order to predict output tokens. Training also had to happen in sequence and this meant two things:
>
> - Very long inputs were _very_ slow to process
> - RNNs had real problems maintaining coherence between tokens far apart from each other.
>
> The combination of sequential processing and weak long-range coherence made very long outputs slow and often incoherent, and not super practical for the average generalist usecases

There's a fun broader tension in AI that's interesting here:

Rule-based AI "hard-codes" rules and patterns to follow, whereas machine learning tries to get systems to "learn" more organically.

So essentially, these opposing fields have argued for ~75 years!

Rule-based says "You cannot rely on statistical behavior to perform expert actions!"

ML scoff's and says "Give us more compute and data and we can get there!" T

The interesting thing is that many of the best agentic systems today are actually a combination of both: encoding expert workflows to "rein in" machine-learning models. Essentially, that's what we're doing with skills and harnesses.

- The [transformer architecture](https://arxiv.org/abs/1706.03762) (Vaswani et al., 2017) changed everything with the attention mechanism: Instead of processing text sequentially like RNNs, it looks at all parts of the input simultaneously

> The key insight was the attention mechanism: instead of processing text sequentially — like RNNs had to — the model could look at all parts of the input simultaneously and learn which parts are relevant to which other parts.

> Those RNNs we just talked about? They had to process tokens one at a time, in order, and training had to happen sequentially too. This meant they couldn't be parallelised, and they struggled to maintain relationships between tokens that were far apart.

> The transformer's attention mechanism solved both problems: it can be done in parallel, and it's much better at computing relationships between ALL the tokens in a long input. In practice, the output of a transformer-based LLM is more likely to be related to everything in the input — not just the nearby tokens.

> This also had a hardware implication (and why Nvidia barely cares about gaming consumers anymore): While attention on a single processor actually uses more time and memory than RNNs, attention can be _massively_ parallelised across GPUs. Machine learning is based on complex math that, in order to process large inputs, needs to be very parallelised. Computer hardware experts had been improving parallel computation mechanisms since the 1960s for graphics rendering — GPUs. The transformer architecture could exploit all that GPU hardware in a way RNNs simply couldn't.

> That single architectural insight is what made everything else possible. Every model you've heard of — GPT, Claude, Gemini, Llama — is a transformer under the hood. One paper, and it changed the entire field.

- Scale did the rest after that:

| Year | What happened |
|------|--------------|
| **2018** | **GPT-1** — proof of concept that transformers could generate text |
| **2019** | **GPT-2** — "Too dangerous to release" (mostly marketing, but outputs were startling) |
| **2020** | **GPT-3** — 175B parameters. Emergent capabilities nobody programmed in |
| **2022** | **Chain-of-thought prompting** — "Let's think step by step" unlocked reasoning |
| **2022** | **ChatGPT** — RLHF made it actually useful to talk to |

- GPT-1 through GPT-3, then RLHF turned "impressive autocomplete" into something you could actually have a conversation with

> Reinforcement Learning from Human Feedback. The roots go back to Christiano et al. in 2017, but OpenAI applied it at scale with InstructGPT (March 2022, Ouyang et al.) which became the foundation for ChatGPT. The idea: have humans rate the model's outputs, then train the model to produce outputs that humans rate highly. Simple concept, transformative result.

- ChatGPT launched November 2022, hit 100 million users in two months

Ted Chiang nailed it best in his [New Yorker piece](https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web):

> ChatGPT is a blurry jpeg of the web

Essentially modern LLM's are squashed-down, lossy-compresed internet snapshot. Plus a bunch of other sources of information like pirated and chopped up books thrown in for funsies.

It's seen everything, but at low resolution, frozen in time.

The problem is, this is a bit of a magic moment and people treat it like a search engine, database, or calculator, when it's none of those things. ]

It's a prediction machine — Given some text, what text is likely to come next?

## Code Is A Natural Fit

The nature of code is that it has stronger token relationships than natural prose, which is why one of the biggest AI usecases where ROI seems the most obvious and has completely changed the software delivery lifecycle is LLMs.

A model trained on software repos sees patterns like `<type> <name> = <value>` millions of times, closing braces following opening brace, function signatures following consistent patterns and so on.

Prose is creative; code is structural, and that's why coding agents have taken off like a rocket once we figured out how to harness them (heh) correctly.

> Code turned out to be a more natural fit for LLM generation because of the strong relationships between its tokens. Training and inference work best when there are consistent patterns in training data and intended output.

> Think about it: while training on data from software repos and the internet, a model is going to "see" variable declaration and assignment over and over again. When it comes time to infer correct code, a line for variable assignment is going to follow that same pattern, even if the type, name, and value are completely different from the training data.

> Unlike complex natural prose, LLMs can better predict things like a closing brace following an open brace, a declared variable being assigned after declaration, function signatures following language-specific conventions. The structural relationships in code are tighter and more predictable than in natural language.

> This explains the progression from 2021 to 2024 — GitHub Copilot (based on OpenAI Codex, a version of GPT-3) and Cursor provided line completion, file scaffolding, and generation of common patterns. The code was rudimentary, localised to common use cases, and highly prone to error — but it worked well enough for simple patterns because those patterns were so consistent in training data. As models got bigger and attention windows grew, they could maintain those structural relationships across longer chains of code, not just single lines.

> This is also why the leap to agentic coding was so dramatic. Once models could maintain structural coherence across hundreds of lines, they went from "autocomplete for single lines" to "write entire functions and files." The structural nature of code made it possible.

## The Four Things That Actually Matter In A Prompt

Since a language model is "predicting" everything, we need to poke it into action, which we call prompting. Prompting can be as simple or as complex as you wish, but the more effort you put in, the better fitting output to your needs you get out.

Per Anthropic's [prompting guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview), a good prompt boils down to 4 core concepts:

**Directness, Context, Output and Examples**

More specifically:

1. **Be clear and direct** — say what you want, specifically
2. **Add context** — the model doesn't know your world, tell it
3. **Specify your output** — JSON, markdown, bullets, whatever — name it
4. **Give examples** — show, don't just tell

Now there's been a lot of shift in what's seen as a good prompt over the last few years. There's a mix of cargo-culting ideas and things that no longer apply in newer models.

For example, for a while, prompting with a specific persona was popular ("You are 10 year experienced Python developer"). However, things like the [Wharton "Prompting Science Report 4"](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5036842) (Mollick et al., December 2025) tested whether expert personas actually improved factual accuracy across six frontier models. Finding: no significant positive effect. What did work? P

Providing direct, relevant information, clear constraints, and examples.

The 4 Horsemen of "The Boring Stuff"

> Few-shot prompting — giving examples — is still one of the most reliable techniques for getting consistent output. The academic backing for this is strong:

> Chain-of-thought prompting (Wei et al., Google Brain, January 2022) showed that just adding "Let's think step by step" to a prompt dramatically improved reasoning tasks. The paper showed a 64.7% to 79.3% jump on the GSM8K math benchmark. That's not a magic trick — it's giving the model room to decompose a problem. It's an example of how the "boring" prompt structure matters more than clever phrasing.

> The Wharton "Prompting Science Report 4" (December 2025) — led by Ethan Mollick's team — tested whether expert personas ("act like a senior oncologist") improve factual accuracy. Tested rigorously across six frontier models. Finding: no significant positive effect. What DOES improve accuracy? Providing relevant information, clear constraints, and concrete examples. The boring fundamentals. Every time.

> There's also the "Lost in the Middle" paper (Liu et al., Stanford, July 2023) which showed that models are better at using information placed at the start or end of the context window — they struggle with information buried in the middle. Practical implication: put your most important context first.

> Without examples, you can get a different format every time — sometimes with emojis, sometimes in past tense, sometimes a paragraph. Examples constrain the output space to exactly what you want.

## Nested layers, Not a Replacement Chain

Prompt Engineering has kind of fallen out of favour, and when I was asked to speak about prompt engineering overall, I realised this was a hard concept to articulate good.

There's a temptation to tell the story as a linear progression:

First prompting, then context engineering, then agentic engineering.

BUT... that framing is wrong. They're _layers_ of the same thing!

- **Prompting** — What you say to the model
- **Context engineering** — What the model can see
- **Agentic engineering** — The model goes and gets what it needs

(With **Intent Engineering** kind of rising in stardom and wrapping up the whole piece, but early days there...)

Each layer wraps the previous on, and a competent agentic system still relies on good prompting at its core.

## "Context Engineering" Has It's Moment

The term crystallised in June 2025. Tobi Lutke (Shopify CEO) and Andrej Karpathy both landed on it within a week of each other.

Karpathy's analogy was that an LLM is like a CPU: It's context window is like RAM, and the engineer's job is to be the operating system — loading just the right code and data for each task.

Phil Schmid from Hugging Face has a good quote here: "Most agent failures are not model failures anymore — they are context failures."

## The Agentic Leap aka "Claude Code as the Dark Horse That Changed Every Companies Approach"

Story time!

Boris Cherny joined Anthropic in September 2024 and started hacking on a terminal prototype. First thing it could do: tell him what song was playing via AppleScript. That was cool enough as another LLM plaything to show colleagues. But he had a bit of a eureka moment: he gave it bash access and filesystem access. From there, it started _exploring_ — reading files, following imports, reading those files.

It was the same core Claude model under the hood, it hadn't suddenly gotten smarter with the harness he'd written around it. It just had access to information it didn't have before.

That terminal toy music player became...

Claude Code.

It's funny how in the gold-rush to figure out the best way to do things with LLM's for the average user, they'd tried various doo-dads and complex systems (RAG, Vector databases, Recursive indexing). But any Linux guru could tell them that some awk + grep + sed will beat that fancy-smancy stuff 9 times out of ten over a codebase to find and change something.

Essentially the Archimedes moment for Claude Code:

> Give me a ~~lever long enough~~ bash understanding and a ~~fulcrum~~tool access on which to ~~place~~ run it, and I shall code ~~move~~ the world!

## The Bottleneck Shifted

However, there's no such thing as a free lunch: the ability of LLMs to produce massive amounts of output and perform actions has moved the bottleneck.

Output in theory is trivial: correctness and figuring out maintainabilty is the key.  

We're in a world where getting LLMs to mark their own homework is sometimes literally just that: A circular loop of needing to check whether they checked their own work correctly!

Bringing back this "Intent engineering" concept from before, you can see why this is gaining traction. The term may-or-may not stick, but the underlying problem is real and pressing:

Being able to specify enough of what you actually want clearly enough for an agent to self-evaluate.

## Sources

- Ted Chiang — [ChatGPT Is a Blurry JPEG of the Web](https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web) (New Yorker, Feb 2023)
- Simon Willison — [Context engineering](https://simonwillison.net/2025/Jun/27/context-engineering/) (June 2025)
- Phil Schmid — [The New Skill in AI is Not Prompting, It's Context Engineering](https://www.philschmid.de/context-engineering) (June 2025)
- Vaswani et al. — [Attention Is All You Need](https://arxiv.org/abs/1706.03762) (2017)
- Wei et al. — [Chain-of-Thought Prompting Elicits Reasoning in Large Language Models](https://arxiv.org/abs/2201.11903) (Jan 2022)
- Mollick et al. — [Prompting Science Report 4](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5036842) (Wharton, Dec 2025)
