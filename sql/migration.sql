-- Migrations for Guest Accounts --------------------------------------------------

-- Add Guest Account role
ALTER TYPE CCG.USER_ROLE ADD VALUE 'guest' BEFORE 'user';

-- Remove Email Not Null constraint (guests have null emails)
ALTER TABLE CCG.Account ALTER COLUMN email DROP NOT NULL;

-- End Migrations for Guest Accounts ----------------------------------------------

-- Add Simple Draft Data
CREATE TABLE CCG.Draft (
    accountID INTEGER NOT NULL,
    draftData JSON NOT NULL,
    FOREIGN KEY (accountID) REFERENCES CCG.Account(accountID)
);

-- Add last login time
ALTER TABLE CCG.Account ADD COLUMN lastActive TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL;
UPDATE CCG.Account SET lastActive = joined;

-- Add tournament data
CREATE TABLE CCG.AITournament (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(30),
    active       BOOLEAN
);

CREATE TABLE CCG.TournamentTeam (
    id           SERIAL PRIMARY KEY,
    tournamentID INTEGER,
    teamName     VARCHAR(30) NOT NULL CHECK(teamName SIMILAR TO '[a-zA-Z0-9]+( [a-zA-Z0-9]+)*'),
    joinCode     TEXT NOT NULL DEFAULT md5(random()::text),
    contactEmail VARCHAR(254) NOT NULL CHECK(LENGTH(contactEmail) > 0),
    contactName  VARCHAR(60) NOT NULL CHECK(LENGTH(teamName) > 0),
    contactOrg   VARCHAR(60) NOT NULL CHECK(LENGTH(contactOrg) > 0),
    FOREIGN KEY (tournamentID) REFERENCES CCG.AITournament(id)
);
CREATE UNIQUE INDEX unique_team_name ON CCG.TournamentTeam (LOWER(teamName));
CREATE UNIQUE INDEX unique_contact_email ON CCG.TournamentTeam (LOWER(contactEmail));

CREATE TABLE CCG.TeamSubmission (
    id           SERIAL PRIMARY KEY,
    owningTeam   INTEGER NOT NULL,
    submitter    INTEGER NOT NULL,
    submitted    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    contents     BYTEA,
    FOREIGN KEY (owningTeam) REFERENCES CCG.TournamentTeam(id) ON DELETE CASCADE,
    FOREIGN KEY (submitter) REFERENCES CCG.Account(accountID) ON DELETE CASCADE
);

CREATE TABLE CCG.TournamentParticipant (
    accountID    INTEGER NOT NULL,
    teamID       INTEGER NOT NULL,
    tournamentID INTEGER NOT NULL,
    isTeamOwner  BOOLEAN NOT NULL,
    FOREIGN KEY (teamId) REFERENCES CCG.TournamentTeam(id) ON DELETE CASCADE,
    FOREIGN KEY (accountID) REFERENCES CCG.Account(accountID) ON DELETE CASCADE,
    FOREIGN KEY (tournamentID) REFERENCES CCG.AITournament(id),
    PRIMARY KEY (accountID, tournamentID)
);


-- Mod Definitions
CREATE TABLE CCG.Card (
    id          UUID PRIMARY KEY,
    ownerID     INTEGER NOT NULL,
    cardData    JSON,
    FOREIGN KEY (ownerID) REFERENCES CCG.Account(accountID) ON DELETE CASCADE
);

CREATE TABLE CCG.Set (
    id             UUID PRIMARY KEY,
    setName        VARCHAR(256) NOT NULL,
    setDescription VARCHAR(1048576),
    ownerID        INTEGER NOT NULL,
    public         BOOLEAN NOT NULL DEFAULT false,
    official       BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY (ownerID) REFERENCES CCG.Account(accountID) ON DELETE CASCADE
);

CREATE TABLE CCG.SetMembership (
    setID       UUID REFERENCES CCG.Set(id) ON DELETE CASCADE,
    cardID      UUID REFERENCES CCG.Card(id) ON DELETE CASCADE,
    PRIMARY KEY (setID, cardID)
);

CREATE TABLE CCG.SetActive (
    setID       UUID REFERENCES CCG.Set(id) ON DELETE CASCADE,
    accountID   INTEGER REFERENCES CCG.Account(accountID) ON DELETE CASCADE,
    PRIMARY KEY (setID, accountID)
);

-- Migrations for account deletion
alter table CCG.Deck
drop constraint ccg.deck.deck_accountid_fkey,
add constraint ccg.deck.deck_accountid_fkey
   foreign key (accountID)
   references CCG.Account(accountID)
   on delete cascade;

alter table CCG.Draft
drop constraint ccg.draft.draft_accountid_fkey,
add constraint ccg.draft.draft_accountid_fkey
   foreign key (accountID)
   references CCG.Account(accountID)
   on delete cascade;