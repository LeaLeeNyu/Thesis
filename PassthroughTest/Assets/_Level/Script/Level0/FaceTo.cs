using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceTo : MonoBehaviour
{
    [SerializeField] private GameObject player;
    void Update()
    {
        Vector3 direction = (player.gameObject.transform.position - gameObject.transform.position).normalized;
        float turnAngle = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg;
        transform.rotation = Quaternion.Euler(0f, turnAngle, 0f);
    }
}
