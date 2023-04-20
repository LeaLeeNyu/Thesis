using System;
using System.Collections.Generic;
using UnityEngine;

namespace eWolf.BookEffectV2
{
    [Serializable]
    public class Details
    {
        public List<Texture> Pages = new List<Texture>();
        public int StartingPage = 0;

        public Texture this[int index]
        {
            get
            {
                return Pages[index];
            }
        }

        public bool CanTurnPage()
        {
            return StartingPage < Pages.Count - 2;
        }

        public Texture LeftPage()
        {
            return Pages[StartingPage];
        }

        public Texture NextLeftPage()
        {
            return Pages[StartingPage + 2];
        }

        public Texture NextRightPage()
        {
            return Pages[StartingPage + 3];
        }

        public Texture RightPage()
        {
            return Pages[StartingPage + 1];
        }

        public void TurnPage()
        {
            StartingPage += 2;
        }

        public void TurnPageBack()
        {
            StartingPage -= 2;
        }
    }
}