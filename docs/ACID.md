# ACID Properties
## The Foundation of Reliable Databases

---

# ACID

ACID ensures your database transactions are reliable and predictable.


---

# Why ACID Matters

Imagine you're transferring €500 from your savings to checking account...

- What if the system crashes after removing money but before adding it?
- What if two people try to buy the last concert ticket simultaneously?
- What if your balance shows €1000 to you but €500 to the bank?

**ACID ensures your data stays consistent and reliable**

---

# The Banking Nightmare Without ACID

```sql
-- Monday 9:00 AM
UPDATE accounts SET balance = balance - 500 WHERE id = 'savings';
-- 💥 SYSTEM CRASH HERE 💥
UPDATE accounts SET balance = balance + 500 WHERE id = 'checking';
```

**Result**: €500 has vanished into the void 😱

---

# ACID = Your Database's Safety Net

- **A**tomicity: All or nothing operations
- **C**onsistency: Rules always apply
- **I**solation: Parallel users don't interfere
- **D**urability: Committed data survives crashes

*Think of it as a contract between you and your database*

---

# Atomicity
## "All or Nothing"

A transaction is like jumping a canyon:

- ✅ You make it completely across
- ❌ You don't make it at all
- ⚠️ There's no "halfway"

```sql
BEGIN TRANSACTION;
  UPDATE inventory SET quantity = quantity - 1 WHERE product = 'PS5';
  UPDATE orders SET status = 'confirmed' WHERE order_id = 123;
  INSERT INTO shipping (order_id, address) VALUES (123, '...');
COMMIT;  -- All 3 succeed, or all 3 fail
```

---

# Atomicity: Real Example

**Spotify adding a song to your playlist:**

```sql
BEGIN TRANSACTION;
  INSERT INTO playlist_songs (playlist_id, song_id) VALUES (42, 999);
  UPDATE playlists SET song_count = song_count + 1 WHERE id = 42;
  UPDATE playlists SET updated_at = NOW() WHERE id = 42;
COMMIT;
```

If ANY step fails → entire operation rolls back → playlist unchanged

---

# Consistency
## "Rules Are Never Broken"

Your database has rules (constraints), and consistency ensures they're ALWAYS true:

- Account balance can't be negative
- Email must be unique
- Order total = sum of item prices
- Student can't enroll in more than 7 courses

**After every transaction, all rules still hold**

---

# Consistency: The Guardian

```sql
-- Rule: Account balance >= 0
CREATE TABLE accounts (
  id INTEGER PRIMARY KEY,
  balance DECIMAL CHECK (balance >= 0)
);

-- This transaction will fail completely (atomicity + consistency)
BEGIN TRANSACTION;
  UPDATE accounts SET balance = balance - 1000 WHERE id = 1;
  -- If balance would go negative, ENTIRE transaction fails
COMMIT;
```

The database is your bodyguard against bad data

---

# Isolation
## "What Happens in Vegas..."

Multiple users, zero interference:

**User A and User B both click "Buy" on the last concert ticket**

```sql
-- User A's transaction (10:00:00.000)
UPDATE tickets SET sold = true WHERE seat = 'A1' AND sold = false;

-- User B's transaction (10:00:00.001)
UPDATE tickets SET sold = true WHERE seat = 'A1' AND sold = false;
```

**Result**: Only ONE succeeds. The other gets "Sorry, sold out!"

---

# Isolation Levels
## Choose Your Protection

1. **READ UNCOMMITTED**: "YOLO mode" (dirty reads possible)
2. **READ COMMITTED**: Can't see uncommitted changes
3. **REPEATABLE READ**: Data won't change during your transaction
4. **SERIALIZABLE**: Fort Knox mode (transactions run as if sequential)

*Higher isolation = Safer but slower*

---

# Isolation: The Instagram Like Problem

Without isolation:
```sql
-- Current likes: 1000
-- User A reads: 1000
SELECT likes FROM posts WHERE id = 99;
-- User B reads: 1000
SELECT likes FROM posts WHERE id = 99;
-- User A updates: 1001
UPDATE posts SET likes = 1001 WHERE id = 99;
-- User B updates: 1001 (should be 1002!)
UPDATE posts SET likes = 1001 WHERE id = 99;
```

**Lost update!** One like vanished 👻

---

# Durability
## "Written in Stone"

Once you get "Transaction Committed" → It survives:
- ⚡ Power outages
- 💥 System crashes
- 🔥 Server room fires (with backups)
- 🌊 Data center floods (with replication)

**How?** Write-Ahead Logging (WAL)
- Every change logged before applying
- Can replay the log after crash

---

# Durability: The Guarantee

```sql
INSERT INTO orders (customer, total) VALUES ('Alice', 99.99);
-- "Transaction Committed" ✅
-- 💥 POWER OUTAGE 💥
-- System restarts...
SELECT * FROM orders WHERE customer = 'Alice';
-- Order is still there!
```

**Your committed data is sacred**

---

# ACID in Different Databases

| Database | ACID? | Notes |
|----------|-------|-------|
| PostgreSQL | ✅ Full ACID | Gold standard |
| MySQL (InnoDB) | ✅ Full ACID | Default engine |
| SQLite | ✅ Full ACID | Even on your phone! |
| MongoDB | ⚠️ Partial | ACID for single documents, multi-doc since v4 |
| Redis | ❌ No | Speed over safety |
| Cassandra | ❌ No | Eventual consistency |

---

# The Cost of ACID

**Nothing is free:**

- 🐢 Performance overhead (locking, logging)
- 💾 Extra storage (transaction logs)
- 🔒 Reduced concurrency (isolation)
- 🏗️ Complex implementation

**But for financial, medical, or critical data: ACID is non-negotiable**

---

# When to Break ACID?

Sometimes you trade ACID for:

- **Speed**: Social media likes (who cares if count is off by 1?)
- **Scale**: Google search index (eventual consistency is OK)
- **Availability**: Netflix viewing history (better available than perfect)

**BASE** (Basically Available, Soft state, Eventual consistency)
= The rebellious cousin of ACID

---

# Quick Quiz

**Which ACID property is violated?**

1. Your bank shows different balances on mobile vs web → **?**
2. Money disappears during a failed transfer → **?**
3. Database accepts a negative age (-5 years old) → **?**
4. Yesterday's confirmed order vanishes after restart → **?**

---

# Quiz Answers

1. Your bank shows different balances on mobile vs web → **Isolation**
2. Money disappears during a failed transfer → **Atomicity**
3. Database accepts a negative age (-5 years old) → **Consistency**
4. Yesterday's confirmed order vanishes after restart → **Durability**

---

# Remember: ACID is Your Friend

- **Atomicity**: All or nothing transactions
- **Consistency**: Rules always enforced
- **Isolation**: Parallel users don't interfere
- **Durability**: Committed = permanent

**When in doubt, choose ACID**
(You can optimize later, but you can't recover lost data)