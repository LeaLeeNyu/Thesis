using eWolf.BookEffectV2.Interfaces;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenBook : MonoBehaviour
{
    public GameObject BookObject;
    private IBookControl _bookControl;
    public void Awake()
    {
        _bookControl = BookObject.GetComponent<IBookControl>();
    }


    public void OpenTheBook()
    {
        _bookControl.OpenBook();
    }


    public void TurnPage()
    {
        if (_bookControl.CanTurnPageForward)
        {
            _bookControl.TurnPage();
        }
    }

}
