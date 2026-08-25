# Watch Spec Concierge

A tiny Rails app that looks up a watch by name and has Gemini research and
structure its specs into a clean card.

## Why this
I wanted something small enough to finish well in the time given, that still
reflects real engineering habits: a single-responsibility service object for
the AI call, a rescue for the obvious failure mode (model doesn't return
clean JSON), and a UI that isn't just a raw text dump.

## Stack
Rails, Tailwind, Gemini API (Google AI Studio) via plain Net::HTTP — no extra
gems needed for the AI call itself.

## What I'd add with more time
- Cache results so repeat lookups don't re-hit the API
- Turbo Stream the response in rather than a full page render
- A couple of request specs around the service object's parse failure path

## Setup
1. `bundle install`
2. Get a free Gemini API key at https://aistudio.google.com/apikey (no credit card required)
3. Add `GEMINI_API_KEY=your-key` to a `.env` file in the project root
4. `bin/dev`
5. Visit localhost:3000