# sixeyed/raffle

Randomly selects one entry from a list, e.g. to choose swag winners.

## Usage

Pass a comma-separated list of entries:

```
docker container run --isolation=process sixeyed/raffle "'John,Paul,George,Ringo'"
```

> You need to escape the list with double- **and** single-quotes.

## Output

Something like:

```
The winner is...
----------------
------------
-----
Paul!
```

> There are delays in the output to build tension.