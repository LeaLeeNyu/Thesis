using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(DialogueSystem))]
[RequireComponent(typeof(CapsuleCollider))]
public class GirlStartDialogue : MonoBehaviour
{
    public Dialogue girlDialogue;
    private DialogueSystem dialogueSystem;
    private bool stateDialogue = false;

    public InputActionReference dialoguRef;

    private void Awake()
    {
        dialogueSystem = GetComponent<DialogueSystem>();    
    }

    private void Start()
    {
        dialoguRef.action.performed += NextSentence;
    }

    private void OnDisable()
    {
        dialoguRef.action.performed -= NextSentence;
    }

    // if player collide with girl, girl start talking
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            stateDialogue = true;
            dialogueSystem.StartDialogue(girlDialogue);
            Debug.Log("player");
        }

        //Debug.Log("Collide");

    }

    private void NextSentence(InputAction.CallbackContext context)
    {
        if(stateDialogue)
        {
            dialogueSystem.DisplayNextSentence();
        }       
    }
}
