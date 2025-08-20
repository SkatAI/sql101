-- Drop table if it exists (careful in production!)
DROP TABLE IF EXISTS movies CASCADE;

-- Create the main movies table
CREATE TABLE movies (
    -- Primary key
    movie_id SERIAL PRIMARY KEY,

    -- Basic movie information
    poster_link TEXT,
    series_title VARCHAR(255) NOT NULL,
    released_year INTEGER CHECK (released_year >= 1900 AND released_year <= 2100),
    certificate VARCHAR(10),  -- PG, R, PG-13, etc.
    runtime VARCHAR(20),  -- Stored as string like "142 min"

    -- Genre and ratings
    genre TEXT,  -- Can contain multiple genres like "Action, Adventure, Sci-Fi"
    imdb_rating DECIMAL(3,1) CHECK (imdb_rating >= 0 AND imdb_rating <= 10),
    overview TEXT,  -- Movie plot description
    meta_score INTEGER CHECK (meta_score >= 0 AND meta_score <= 100),

    -- People involved
    director VARCHAR(100),
    star1 VARCHAR(100),
    star2 VARCHAR(100),
    star3 VARCHAR(100),
    star4 VARCHAR(100),

    -- Popularity and revenue
    no_of_votes INTEGER,
    gross VARCHAR(20)  -- Stored as string with commas like "28,341,469"
);