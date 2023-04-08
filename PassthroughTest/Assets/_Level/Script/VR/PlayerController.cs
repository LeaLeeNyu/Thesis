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
    [SerializeField] private InputActionReference jumpReference;
    [SerializeField] private float jumpForce = 100f;
    [SerializeField] private GameObject checkGround;
    [SerializeField] private float yDistance;

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
    }

    private void OnDisable()
    {
        jumpReference.action.performed -= OnJump;
    }



    void OnJump(InputAction.CallbackContext context)
    {
        bool canJump = isGrounded();
        Debug.Log(canJump);
        //Debug.Log(canJump);
        if (canJump)
            _rigidbody.AddForce(Vector3.up * jumpForce);
    }

    private void Update()
    {

    }

}
