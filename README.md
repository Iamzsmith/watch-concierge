# Watch Spec Concierge

A tiny Rails app that looks up a watch by name and has Gemini research and
structure its specs into a clean card.

## Why this
I was told not to sink more than an hour into this, so I picked something
small enough to actually finish well instead of something ambitious that'd
end up half-done. It's simple, but it's built the way I'd actually build
something real: a single-responsibility service object for the AI call, a
rescue for the obvious failure mode (model doesn't return clean JSON), and a
UI that isn't just a raw text dump on the page.

## Stack
Rails, Tailwind, Gemini API (Google AI Studio) via plain Net::HTTP. Didn't
need an extra gem just for the AI call.

## What I'd add with more time

**More idiomatic Rails**
- Move the Gemini call into an ActiveJob (`WatchLookupJob`) with Turbo
  Streams pushing the result back when it's done, instead of blocking the
  request on an external API call. That's the pattern I'd actually reach for
  once a call is slow or flaky enough that you don't want it tying up a web
  worker.
- Rails encrypted credentials instead of dotenv for the API key — more
  idiomatic than reaching for a gem for something Rails already handles.
- A `WatchQuery` form object (ActiveModel::Model) to own input validation and
  normalization instead of handling blank/malformed input inline in the
  controller.
- Fragment caching on the rendered card, keyed on the normalized query — a
  lighter option than a full search-history table if persistence ends up
  being overkill for what this needs.

**Testing**
- RSpec, with request specs covering the happy path and the
  malformed-JSON/blank-query edge cases, plus a unit spec on
  `WatchLookupService` with the HTTP call stubbed via WebMock.

**UI polish**
- A skeleton loader instead of the current disable-on-submit state, so the
  card shape shows up right away while the API call is in flight rather than
  just a disabled button. Could also stand to actually style the disabled
  state so it looks disabled instead of just acting like it.
- Pull the result card into a ViewComponent (`WatchCardComponent`) with a
  real API — same pattern I'd use on an actual redesign: give reusable UI
  pieces a clean interface instead of letting view state leak into a
  partial.
- Real product images per watch, probably via a licensed image API rather
  than asking the model for image URLs directly — LLMs hallucinate URLs that
  don't resolve to real images often enough that I'd rather ship a
  placeholder icon than a broken-image gamble.

**Persistence**
- A `searches` table (MySQL/Postgres) to store each query + result, so
  repeat lookups skip the API entirely and there's an actual history of
  what's been searched. Basically gets caching for free too, since a DB
  lookup on the normalized query would run before ever hitting Gemini.

**Reliability**
- A read timeout on the outbound HTTP call so a slow or hung Gemini request
  doesn't hang the whole app.
- Handle Gemini's free-tier 429s explicitly — should show something like
  "try again in a moment" instead of the generic parse-error message.

## Setup
1. `bundle install`
2. Grab a free Gemini API key at https://aistudio.google.com/apikey (no
   credit card needed)
3. Add `GEMINI_API_KEY=your-key` to a `.env` file in the project root
4. `bin/dev`
5. Visit localhost:3000