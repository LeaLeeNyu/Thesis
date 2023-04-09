using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChickAnimationController : MonoBehaviour
{
    private Animator chickAnimator;

    private void Awake()
    {
        chickAnimator = GetComponent<Animator>();
    }


    public void FinishJump()
    {
        chickAnimator.SetBool("jump", false);
    }

    
}
