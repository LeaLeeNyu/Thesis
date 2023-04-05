using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(DialogueSystem))]
[RequireComponent(typeof(CapsuleCollider))]
public class StartDialogue : MonoBehaviour
{
    public Dialogue dialogue;
    private DialogueSystem dialogueSystem;
    private bool startDialogue = false;

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
        if (other.gameObject.tag == "Player" && !startDialogue)
        {
            startDialogue = true;
            dialogueSystem.StartDialogue(dialogue);
            Debug.Log("player");
        }

        //Debug.Log("Collide");

    }

    private void NextSentence(InputAction.CallbackContext context)
    {
        if(startDialogue && !dialogueSystem.end)
        {
            dialogueSystem.DisplayNextSentence();
        }       
    }
}
