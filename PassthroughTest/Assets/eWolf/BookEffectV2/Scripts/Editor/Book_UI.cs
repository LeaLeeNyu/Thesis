using eWolf.BookEffectV2;
using System.Reflection.Emit;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Book))]
public class Book_UI : Editor
{
    private Book _node;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        GUILayout.Label("NOTE: Starting Page numbers has to be even number.");

        if (_node.Details.StartingPage % 2 == 1)
        {
            _node.Details.StartingPage += 1;
        }
    }

    private void OnEnable()
    {
        _node = (Book)target;
    }
}
