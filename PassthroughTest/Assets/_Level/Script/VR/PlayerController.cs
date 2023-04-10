using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.GraphicsBuffer;
using UnityEngine.SceneManagement;
using System;

public class PlayerController : MonoBehaviour
{
    //Jump related parameter 
    [SerializeField] private InputActionReference jumpReference;
    [SerializeField] private float jumpForce = 100f;
    [SerializeField] private GameObject checkGround;
    public string leftHandName;

    //Walk related parameter
    [SerializeField] private InputActionReference walkReference;

    private Animator chickAnimator;

    private Rigidbody _rigidbody;

    //private bool _isGrounded =>
    //    Physics.Raycast(new Vector2(checkGround.transform.position.x, checkGround.transform.position.y + 2f), Vector3.down, 2.1f);


    private bool isGrounded()
    {
        bool onGround = false;
        Collider[] colliders = Physics.OverlapSphere(checkGround.transform.position, 0.1f);
        foreach (Collider collider in colliders)
        {
            //building material layer index 7, ground layer index 8
            if (collider.tag == "Ground" || collider.tag == "Material")
            {
                onGround = true;
            }
        }
        return onGround;
    }

    private void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        jumpReference.action.performed += OnJump;
        walkReference.action.performed += OnMove;
        //chickAnimator = GameObject.Find(leftHandName).transform.GetChild(0).GetComponent<Animator>();
    }

    private void OnDisable()
    {
        jumpReference.action.performed -= OnJump;
        walkReference.action.performed -= OnMove;
    }

    void OnJump(InputAction.CallbackContext context)
    {
        bool canJump = isGrounded();
        Debug.Log(canJump);
        //Debug.Log(canJump);
        if (canJump)
            _rigidbody.AddForce(Vector3.up * jumpForce);

        if (chickAnimator != null)
        {
            chickAnimator.SetBool("jump", true);
        }
        else
        {
            chickAnimator = GameObject.Find(leftHandName).transform.GetChild(0).GetComponent<Animator>();
        }
    }

    void OnMove(InputAction.CallbackContext context)
    {
        Vector2 controller = context.ReadValue<Vector2>();

        if(chickAnimator != null &&(controller.x>0.1f || controller.y > 0.1f))
        {
            chickAnimator.SetBool("walk", true);
        }
        else if(chickAnimator== null)
        {
            chickAnimator = GameObject.Find(leftHandName).transform.GetChild(0).GetComponent<Animator>();
        }
        else
        {
            chickAnimator.SetBool("walk", false);
        }
    }

}
