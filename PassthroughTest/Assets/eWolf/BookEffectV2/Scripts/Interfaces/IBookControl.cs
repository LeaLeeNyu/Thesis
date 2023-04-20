namespace eWolf.BookEffectV2.Interfaces
{
    public interface IBookControl
    {
        /// <summary>
        /// Can we turn the back backwards
        /// </summary>
        /// <returns>True if we can turn the page backwards</returns>
        bool CanTurnPageBackWard { get; }

        /// <summary>
        /// Can we turn the back forward (normal direction)
        /// </summary>
        /// <returns>True if we can turn the page forward</returns>
        bool CanTurnPageForward { get; }

        /// <summary>
        /// Get the book details
        /// </summary>
        /// <returns>The book details</returns>
        Details GetDetails { get; }

        /// <summary>
        /// Is the book currently open
        /// </summary>
        /// <returns>True if the book is open</returns>
        bool IsBookOpen { get; }

        /// <summary>
        /// Close the Book
        /// </summary>
        void CloseBook();

        /// <summary>
        /// Open the book
        /// </summary>
        void OpenBook();

        /// <summary>
        /// Open the book at a set page.
        /// </summary>
        /// <param name="pageIndex">The page number to open the book at</param>
        void OpenBookAtPage(int pageIndex);

        /// <summary>
        /// Set the animation speed for the book
        /// </summary>
        /// <param name="speed">The animation speed.</param>
        void SetSpeed(float speed);

        /// <summary>
        /// Trun the page forward (normal)
        /// </summary>
        void TurnPage();

        /// <summary>
        /// Turn the page backwards
        /// </summary>
        void TurnPageBack();
    }
}