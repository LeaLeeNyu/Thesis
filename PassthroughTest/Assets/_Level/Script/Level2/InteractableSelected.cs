using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class InteractableSelected : MonoBehaviour
{
    public static UnityAction inteactableSelected = delegate { };

    public void InteractableFirstSelected()
    {
        inteactableSelected.Invoke();
    }
}
