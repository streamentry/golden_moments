interface TodayClearAllConfirmationProps {
  hidden: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/** Explicit confirmation for deleting local Today notes. */
export function TodayClearAllConfirmation({ hidden, onConfirm, onCancel }: TodayClearAllConfirmationProps) {
  return (
    <div
      id="today-clear-all-confirmation"
      className="today__clear-confirm no-print"
      role="group"
      aria-labelledby="today-clear-all-question"
      hidden={hidden}
    >
      <p id="today-clear-all-question">Remove all notes saved in this browser? This cannot be undone.</p>
      <div className="btn-row">
        <button type="button" className="btn btn--quiet" onClick={onConfirm}>
          Remove all notes
        </button>
        <button type="button" className="btn btn--quiet" onClick={onCancel}>
          Keep notes
        </button>
      </div>
    </div>
  );
}
