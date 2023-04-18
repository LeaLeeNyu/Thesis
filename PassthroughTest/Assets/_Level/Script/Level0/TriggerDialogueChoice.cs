using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerDialogueChoice : MonoBehaviour
{
    [SerializeField] private GameObject dialogueBall;

    private void OnEnable()
    {
        ActiveDialogueChoice.activeDialogue += ShowDialogueChoice;
    }

    private void OnDisable()
    {
        ActiveDialogueChoice.activeDialogue -= ShowDialogueChoice;
    }

    private void ShowDialogueChoice()
    {
        dialogueBall.SetActive(true);
    }
}
