using UnityEngine;

public class AvatarReflector : MonoBehaviour
{
    [Header("Core Transforms")]
    [Tooltip("The Transform representing the user's real-time head pose (the AR camera).")]
    public Transform HeadTrackingSource;

    [Tooltip("The fixed world position that acts as the virtual mirror plane.")]
    public Transform MirrorPlaneAnchor;

    [Tooltip("The actual GameObject Transform for the avatar's head (the Sphere).")]
    public Transform AvatarHead;

    [Tooltip("Vertical offset to correctly position the avatar's feet.")]
    public float VerticalOffset = -0.5f;

    void Update()
    {
        if (HeadTrackingSource == null || MirrorPlaneAnchor == null || AvatarHead == null)
        {
            Debug.LogError("Required Transforms (HeadTrackingSource, MirrorPlaneAnchor, or AvatarHead) are not assigned in the Inspector.");
            return;
        }

        // Position Calculation for the AVATAR
        Vector3 cameraPosition = HeadTrackingSource.position;
        Vector3 anchorPosition = MirrorPlaneAnchor.position;
        Vector3 delta = cameraPosition - anchorPosition;

        Vector3 reflectedPosition;
        reflectedPosition.x = anchorPosition.x + delta.x; // Parallel X (Left/Right)
        reflectedPosition.y = anchorPosition.y + delta.y + VerticalOffset; // Parallel Y (Up/Down) + offset
        reflectedPosition.z = anchorPosition.z - delta.z; // Mirrored Z (Forward/Back)

        transform.position = reflectedPosition;

        // Rotation Calculation for the AVATAR HEAD

        Quaternion headRotation = HeadTrackingSource.rotation;

        Vector3 eulerAngles = headRotation.eulerAngles;

        // Mirror rotation

        float pitch = eulerAngles.x;

        float yaw = eulerAngles.y + 180f;

        float roll = -eulerAngles.z;

        // Apply mirrored rotation
        AvatarHead.localRotation = Quaternion.Euler(pitch, yaw, roll);

        // Quit Application 
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Debug.Log("Back button pressed. Quitting application...");
            Application.Quit();
        }
    }
}