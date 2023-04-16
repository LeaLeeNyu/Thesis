using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.XR;

public class MemoBallCollide : MonoBehaviour
{
    private bool onPosition = false;
    [SerializeField] private string memoSceneName;

    public void BallOnPosition()
    {
        onPosition = true;
    }

    private void OnCollisionEnter(Collision other)
    {
        Debug.Log("Enter Dream Ball");
        if(other.gameObject.tag == "Player" && onPosition)
        {
            SceneManager.LoadScene(memoSceneName);
        }
    }
}
