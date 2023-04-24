using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;

public class Raycast : MonoBehaviour
{
    private GameObject waterCharacter;
    public static UnityAction ActiveHi = delegate { };
    public static UnityAction ActiveWater = delegate { };
    public static UnityAction ActiveSit = delegate { };

    public GameObject textOne;
    public GameObject textTwo;
    public GameObject textThree;

    private void Update()
    {
        Vector3 rayOrigin = transform.position;
        Vector3 rayDirection = -transform.up;
        Ray ray = new Ray(rayOrigin, rayDirection);

        Debug.DrawRay(rayOrigin, rayDirection, Color.green);

        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            if(hit.collider.tag == "GFWater" )
            {
                ActiveWater.Invoke();
                textOne.SetActive(false);
                textTwo.SetActive(true);
                textThree.SetActive(false);
            }
            else if (hit.collider.tag == "GFSit")
            {
                ActiveSit.Invoke();
                textOne.SetActive(false);
                textTwo.SetActive(false);
                textThree.SetActive(true);
            }
            else if (hit.collider.tag == "GFHi")
            {
                ActiveHi.Invoke();
                textOne.SetActive(true);
                textTwo.SetActive(false);
                textThree.SetActive(false);
            }
            else
            {
                textOne.SetActive(false);
                textTwo.SetActive(false);
                textThree.SetActive(false);
            }
        }
    }


}
