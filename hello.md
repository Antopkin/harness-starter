# First exercise: check that the harness is connected

The goal is to make sure, in a couple of minutes, that the agent sees the rules and skills and that it shows a plan before it acts. Run three small steps.

## Step 1. Ask the agent about its rules and skills

Tell the agent:

> Read `AGENTS.md` and tell me in your own words: what are your rules of behaviour, and which skills and agent roles are available to you? List the skills with one line about each.

A good answer: the agent names three or four key rules (for example "show a plan before code", "change only what was asked", "do not touch secrets", "ask before merging a pull request") and lists the skills from the table in `INSTALL.md`. If the agent does not see the skills, go back to `INSTALL.md`, step 3, and check that they are connected.

## Step 2. Give it a tiny task and demand a plan before code

Give the agent any micro-task, for example:

> Create a file `hello.txt` with the line "the harness works", but **show me the plan first**: what exactly you will do. Do not start until I say "ok".

A good answer: the agent **first** describes a one- or two-line plan and **waits** for your "ok", and only then creates the file. That is the main rule of the harness: think and show your intent before acting.

## Step 3. Write the first fact into memory

When everything worked, ask:

> Add a short memory note that the harness is set up: the fact, why it matters and how to apply it. Link it from `memory/MEMORY.md`.

The agent should create a note in `memory/` with the frontmatter shown in `memory/MEMORY.md` and add a `[[name]]` line to the index.

Now the agent is "inside the harness": it knows the rules, has the skills and keeps a memory. You can get to work.
