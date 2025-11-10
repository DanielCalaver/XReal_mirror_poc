// This shader is for the "MirrorSurface" plane.
// It is completely invisible but writes a value (1) to the Stencil Buffer.
// This creates the "window" that the avatar can be seen through.
Shader "Tutorial/MirrorMask"
{
    SubShader
    {
        // We want this to render before the avatar, so we use the Geometry queue
        Tags { "Queue"="Geometry-10" }

        // Do not write to color or depth buffers
        ColorMask 0
        ZWrite Off

        // Stencil properties
        Stencil
        {
            Ref 1           // The value to write (1)
            Comp Always     // Always pass the stencil test
            Pass Replace    // If the test passes, replace the buffer value with 1
        }

        Pass {}
    }
}