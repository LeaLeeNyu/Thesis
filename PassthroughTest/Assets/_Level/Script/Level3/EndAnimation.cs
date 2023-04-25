using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndAnimation : MonoBehaviour
{
    [SerializeField] private Animator animator;
    public string animationParameter;

    public void PlayAnimation()
    {
        animator.SetBool(animationParameter, true);
    }
}
