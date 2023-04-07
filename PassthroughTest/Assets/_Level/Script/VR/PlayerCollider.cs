using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//this script makes the collider turn around with headset
public class PlayerCollider : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;

    private void Start()
    {
        transform.rotation = Quaternion.Euler(transform.rotation.x, mainCamera.transform.eulerAngles.y, transform.rotation.z);
    }

    private void Update()
    {
        transform.position = new Vector3(mainCamera.transform.position.x, transform.position.y, mainCamera.transform.position.z);
        //transform.rotation = Quaternion.Euler(transform.rotation.x, mainCamera.transform.eulerAngles.y, transform.rotation.z);
    }
}
