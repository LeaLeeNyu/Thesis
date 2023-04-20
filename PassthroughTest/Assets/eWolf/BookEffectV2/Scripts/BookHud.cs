using eWolf.BookEffectV2.Interfaces;
using UnityEngine;

namespace eWolf.BookEffectV2
{
    public class BookHud : MonoBehaviour
    {
        public GameObject BookObject;
        private IBookControl _bookControl;

        public void OnGUI()
        {
            if (_bookControl.IsBookOpen)
            {
                if (GUI.Button(new Rect(10, 80, 120, 48), "Close Book"))
                {
                    _bookControl.CloseBook();
                }
            }
            else
            {
                if (GUI.Button(new Rect(10, 10, 120, 48), "Open Book"))
                {
                    _bookControl.OpenBook();
                }
                if (GUI.Button(new Rect(200, 10, 120, 48), "Open Book Page 0"))
                {
                    _bookControl.OpenBookAtPage(0);
                }
                if (GUI.Button(new Rect(330, 10, 120, 48), "Open Book Page 2"))
                {
                    _bookControl.OpenBookAtPage(2);
                }
                if (GUI.Button(new Rect(460, 10, 120, 48), "Open Book Page 4"))
                {
                    _bookControl.OpenBookAtPage(4);
                }
            }

            if (_bookControl.CanTurnPageForward)
            {
                if (GUI.Button(new Rect(200, 80, 80, 40), "Turn"))
                {
                    _bookControl.TurnPage();
                }
            }
            if (_bookControl.CanTurnPageBackWard)
            {
                if (GUI.Button(new Rect(300, 80, 80, 40), "Turn-Back"))
                {
                    _bookControl.TurnPageBack();
                }
            }

            if (GUI.Button(new Rect(10, 200, 80, 40), "Speed 1"))
            {
                _bookControl.SetSpeed(1);
            }
            if (GUI.Button(new Rect(10, 250, 80, 40), "Speed 2"))
            {
                _bookControl.SetSpeed(2);
            }
            if (GUI.Button(new Rect(10, 300, 80, 40), "Speed 4"))
            {
                _bookControl.SetSpeed(4);
            }
        }

        public void Start()
        {
            _bookControl = BookObject.GetComponent<IBookControl>();
        }
    }
}