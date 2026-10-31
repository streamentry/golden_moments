import { pictureUrl } from '../../data/pictures';
import type { PlayProps, PlayUi } from '../../i18n/play';
import { fill } from '../../i18n/play/format';
import { Icon } from './Icon';

export type TileState = 'resting' | 'selected' | 'matched' | 'hidden' | 'mismatch';

interface PictureTileProps {
  ui: PlayUi;
  /** A picture id from the library, or a photo object URL when `photo` is set. */
  value: string;
  photo?: boolean;
  /** The spoken name of the picture or photo. */
  name: string;
  position: number;
  state: TileState;
  onTap: () => void;
}

/** A picture's name in the page language, for any id in the library. */
export function pictureNamer({ pictureNames, ui }: Pick<PlayProps, 'pictureNames' | 'ui'>): (id: string) => string {
  return (id) => pictureNames[id] ?? ui.tile.picture;
}

export function PictureTile({ ui, value, photo = false, name, position, state, onTap }: PictureTileProps) {
  const hidden = state === 'hidden';
  const spoken = fill(hidden ? ui.tile.hidden : ui.tile.named, { name, n: position });
  const stateWord = state === 'matched' ? ui.tile.matched : state === 'selected' ? ui.tile.selected : undefined;
  return (
    <button
      type="button"
      className={`tile tile--${state}`}
      onClick={onTap}
      aria-label={stateWord ? fill(ui.tile.withState, { label: spoken, state: stateWord }) : spoken}
      aria-pressed={state === 'selected' ? true : undefined}
      aria-disabled={state === 'matched' ? true : undefined}
    >
      {hidden ? (
        <span className="tile__back" aria-hidden="true">
          <Icon name="photo" size={40} />
        </span>
      ) : (
        <img src={photo ? value : pictureUrl(value)} alt="" draggable={false} />
      )}
      {state === 'matched' ? (
        <span className="tile__badge" aria-hidden="true">
          <Icon name="check" size={22} />
        </span>
      ) : null}
    </button>
  );
}
