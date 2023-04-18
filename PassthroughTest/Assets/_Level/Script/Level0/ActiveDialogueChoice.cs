using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ActiveDialogueChoice : MonoBehaviour
{
    public static UnityAction activeDialogue = delegate { };

    public void ActiveDialogue()
    {
        activeDialogue.Invoke();
    }
}
