import { GAMES, type GameInfo, type GameSlug } from '../data/games';
import { pictureUrl } from '../data/pictures';
import type { ActivityChoice } from '../lib/today/situations';

const GAME_BY_SLUG = new Map<GameSlug, GameInfo>(GAMES.map((game) => [game.slug, game]));

interface ActivityChoiceBoardProps {
  choices: readonly [ActivityChoice, ActivityChoice];
}

interface ChoiceLinkData {
  key: string;
  href: string;
  picture: string;
  title: string;
  description: string;
}

function choiceLinkData(choice: ActivityChoice): ChoiceLinkData | undefined {
  if (typeof choice === 'string') {
    const game = GAME_BY_SLUG.get(choice);
    const picture = game?.cardPictures[0];
    if (!game || !picture) return undefined;

    return {
      key: game.slug,
      href: `/games/${game.slug}/`,
      picture,
      title: game.name,
      description: game.short,
    };
  }

  return {
    key: choice.href,
    href: choice.href,
    picture: choice.picture,
    title: choice.label,
    description: choice.description,
  };
}

/** Two pictured activity links for a caregiver to offer together. */
export function ActivityChoiceBoard({ choices }: ActivityChoiceBoardProps) {
  return (
    <section className="today__activity-board" aria-labelledby="today-activity-board-title">
      <h3 id="today-activity-board-title">Choose one together</h3>
      <p>Show both pictures and wait. They can point; you can tap.</p>
      <ul className="today__activity-choices">
        {choices.map((choice) => {
          const link = choiceLinkData(choice);
          if (!link) return null;

          return (
            <li key={link.key}>
              <a className="today__activity-choice" href={link.href}>
                <img src={pictureUrl(link.picture)} alt="" width={96} height={96} />
                <span className="today__activity-choice-copy">
                  <strong>{link.title}</strong>
                  <span>{link.description}</span>
                </span>
              </a>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
