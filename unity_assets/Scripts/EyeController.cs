using UnityEngine;

public class EyeController : MonoBehaviour
{
    public Transform rightEye;
    public Transform leftEye;
    public Transform torchlight;

    private string currentPathology = "Normal";

    // Called by Flutter
    public void SetGaze(string gazeData)
    {
        // Expected format: "x,y" where x and y are between -1 and 1
        string[] coords = gazeData.Split(',');
        if (coords.Length == 2)
        {
            float gazeX = float.Parse(coords[0]);
            float gazeY = float.Parse(coords[1]);
            ApplyGaze(gazeX, gazeY);
        }
    }

    // Called by Flutter
    public void SetPathology(string pathology)
    {
        currentPathology = pathology;
        // Reset to primary gaze
        ApplyGaze(0, 0);
    }

    // Called by Flutter
    public void MoveTorch(string positionData)
    {
        // Expected format: "x,y,z"
        string[] coords = positionData.Split(',');
        if (coords.Length == 3)
        {
            float x = float.Parse(coords[0]);
            float y = float.Parse(coords[1]);
            float z = float.Parse(coords[2]);
            if (torchlight != null)
            {
                torchlight.position = new Vector3(x, y, z);
            }
        }
    }

    private void ApplyGaze(float gazeX, float gazeY)
    {
        // Base rotation angles (e.g., 40 degrees max rotation)
        float maxAngleX = 40f; 
        float maxAngleY = 40f;

        float targetRightX = gazeX * maxAngleX;
        float targetRightY = gazeY * maxAngleY;
        
        float targetLeftX = gazeX * maxAngleX;
        float targetLeftY = gazeY * maxAngleY;

        // Apply Pathology Overrides (Strabismus & Palsies logic)
        switch (currentPathology)
        {
            case "Right 6th Nerve Palsy":
                // Right eye cannot abduct (move right)
                if (targetRightX > 0) targetRightX = 0;
                break;

            case "Left 6th Nerve Palsy":
                // Left eye cannot abduct (move left)
                if (targetLeftX < 0) targetLeftX = 0;
                break;

            case "Right 3rd Nerve Palsy":
                // Right eye rests "down and out", cannot elevate, depress normally, or adduct
                if (targetRightX < 0) targetRightX = 0; // cannot adduct (left)
                if (targetRightY > 0) targetRightY = 0; // cannot elevate
                // Resting position
                if (gazeX == 0 && gazeY == 0)
                {
                    targetRightX = 20f; // Out
                    targetRightY = -15f; // Down
                }
                break;
                
            case "Duane Type 1 (Left)":
                // Limited abduction in left eye
                if (targetLeftX < 0) targetLeftX = 0; 
                // Retraction on adduction (would need to move Z axis of eye transform, simplified here)
                break;
        }

        // Apply Rotations (Assuming Z is forward, Y is up, X is right)
        // Note: Unity rotation X is up/down (pitch), Y is left/right (yaw)
        if (rightEye != null)
            rightEye.localRotation = Quaternion.Euler(-targetRightY, targetRightX, 0);
            
        if (leftEye != null)
            leftEye.localRotation = Quaternion.Euler(-targetLeftY, targetLeftX, 0);
    }
}
