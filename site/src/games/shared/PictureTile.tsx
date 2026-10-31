import { pictureUrl, PICTURE_BY_ID } from '../../data/pictures';
import { Icon } from './Icon';

export type TileState = 'resting' | 'selected' | 'matched' | 'hidden' | 'mismatch';

interface PictureTileProps {
  /** A picture id from the library, or a photo object URL when `photo` is set. */
  value: string;
  photo?: boolean;
  label?: string;
  position: number;
  state: TileState;
  onTap: () => void;
}

export function pictureName(id: string): string {
  return PICTURE_BY_ID.get(id)?.name ?? 'Picture';
}

export function PictureTile({ value, photo = false, label, position, state, onTap }: PictureTileProps) {
  const name = label ?? (photo ? `Photo` : pictureName(value));
  const hidden = state === 'hidden';
  const spoken = hidden ? `Hidden picture, tile ${position}` : `${name}, tile ${position}`;
  const stateWord = state === 'matched' ? 'Matched' : state === 'selected' ? 'Selected' : undefined;
  return (
    <button
      type="button"
      className={`tile tile--${state}`}
      onClick={onTap}
      aria-label={stateWord ? `${spoken}, ${stateWord}` : spoken}
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
