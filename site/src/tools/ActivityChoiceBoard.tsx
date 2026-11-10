import { GAMES, type GameInfo, type GameSlug } from '../data/games';
import { pictureUrl } from '../data/pictures';

const GAME_BY_SLUG = new Map<GameSlug, GameInfo>(GAMES.map((game) => [game.slug, game]));

interface ActivityChoiceBoardProps {
  choices: readonly [GameSlug, GameSlug];
}

/** Two picture links for a caregiver to offer when an open-ended list is too much. */
export function ActivityChoiceBoard({ choices }: ActivityChoiceBoardProps) {
  return (
    <section className="today__activity-board" aria-labelledby="today-activity-board-title">
      <h3 id="today-activity-board-title">Choose one together</h3>
      <p>Show both pictures and wait. They can point; you can tap.</p>
      <ul className="today__activity-choices">
        {choices.map((slug) => {
          const game = GAME_BY_SLUG.get(slug);
          if (!game) return null;

          return (
            <li key={slug}>
              <a className="today__activity-choice" href={`/games/${game.slug}/`}>
                <img src={pictureUrl(game.cardPictures[0])} alt="" width={96} height={96} />
                <span className="today__activity-choice-copy">
                  <strong>{game.name}</strong>
                  <span>{game.short}</span>
                </span>
              </a>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
