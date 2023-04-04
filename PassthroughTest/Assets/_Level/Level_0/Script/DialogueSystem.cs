using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Linq;

public class DialogueSystem : MonoBehaviour
{

    private Queue<string> sentences;
    private Queue<string> animationP;

    private DialogueSystem instance;

    public TextMeshProUGUI dialogueSentence;

    public GameObject dialogueCanvas;

    //control animation
    private int dialougueAmount;
    private Animator girlAnimator;

    //control whether the dialogue ends
    public bool end = false;


    private void Awake()
    {
        girlAnimator = GetComponent<Animator>();
    }

    void Start()
    {
        //create a queue for stroing dialogue dialogues
        sentences = new Queue<string>();
        //create a queue for animation parameter
        animationP = new Queue<string>();
    }

    //input the dialogue dialogues into queue, and output the first sentence in the queue
    public void StartDialogue(Dialogue dialogue)
    {
        dialougueAmount = dialogue.dialogues.Length;
        Debug.Log(dialougueAmount);
        // clear all the object in dialogues
        sentences.Clear();
        animationP.Clear();

        // enqueue the dialogues in Dialogue script
        foreach (string sentence in dialogue.dialogues)
        {
            sentences.Enqueue(sentence);
        }
        //enqueue the animation paramter in Dialogue script
        foreach (string animationParameter in dialogue.animationParameters)
        {
            animationP.Enqueue(animationParameter);
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

        // Change animation
        //Debug.Log(sentences.Count);
        string nextAnimation = animationP.Dequeue();
        girlAnimator.SetBool(nextAnimation, true);

        // output the first sentence in the queue
        string dialogueSentence = sentences.Dequeue();
        this.dialogueSentence.text = dialogueSentence;
        //Debug.Log(dialogueSentence);

    }

    void EndDialogue()
    {
        dialougueAmount = 0;
        end = true;
    }

}
