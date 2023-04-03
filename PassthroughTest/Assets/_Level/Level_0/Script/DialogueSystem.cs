using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class DialogueSystem : MonoBehaviour
{

    private Queue<string> sentences;

    private DialogueSystem instance;

    public TextMeshProUGUI dialogueSentence;

    public GameObject dialogueCanvas;

    // to control when the dialogue shows up, the player cannot move
    public bool noDialogue = true;


    void Start()
    {
        //create a queue for stroing dialogue sentences
        sentences = new Queue<string>();
    }

    //input the dialogue sentences into queue, and output the first sentence in the queue
    public void StartDialogue(Dialogue dialogue)
    {

        noDialogue = false;

        // clear all the object in sentences
        sentences.Clear();

        // enqueue the sentences in Dialogue script
        foreach (string sentence in dialogue.sentences)
        {
            sentences.Enqueue(sentence);
        }

        DisplayNextSentence();

    }

    public void DisplayNextSentence()
    {
        //if there is no sentence in queue, said"ENd" and return
        if (sentences.Count == 0)
        {
            EndDialogue();
            return;
        }

        // output the first sentence in the queue
        string dialogueSentence = sentences.Dequeue();
        this.dialogueSentence.text = dialogueSentence;
        //Debug.Log(dialogueSentence);
    }

    void EndDialogue()
    {
        //The dialogue ends.
        noDialogue = true;
    }

}
