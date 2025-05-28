#!/usr/bin/env python3
import pya
from datetime import datetime

# ========================= Configuration =========================
INPUT_FILE = "/path/to/input.gds"        # Input GDS file path
OUTPUT_FILE = "/path/to/output.gds"      # Output file path with timestamp
DBU_PER_MICRON = 1000                    # Database units per micron :ml-citation{ref="5" data="citationList"}

# Layers to delete [(layer, datatype), ...]
DELETE_LAYERS = [
    (1, 0), 
    (3, 5), 
    (6, 10)
]

# New layers to create with rectangles
CREATE_LAYERS = [
    {
        'layer': (2, 0),          # New layer definition
        'rect_um': [0, 0, 1000, 500],  # Rectangle in microns
        'comment': "Main routing layer"
    },
    {
        'layer': (4, 0),
        'rect_um': [200, 200, 800, 800],
        'comment': "Power plane layer"
    }
]  
# ================================================================

def timestamp():
    """Generate formatted timestamp for logs"""
    return datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")

def delete_target_layers(layout):
    """Batch delete multiple layers with validation"""
    deleted_count = 0
    for target in DELETE_LAYERS:
        layer_found = False
        for li in layout.layer_indices():
            info = layout.get_info(li)
            if (info.layer, info.datatype) == target:
                layout.delete_layer(li)
                print(f"{timestamp()} Deleted layer {target[0]}/{target[1]}")
                deleted_count += 1
                layer_found = True
                break
        if not layer_found:
            print(f"{timestamp()} Warning: Layer {target} not found")
    return deleted_count

def create_new_layers(layout):
    """Create layers with micron-based geometries"""
    for config in CREATE_LAYERS:
        # Micron to DBU conversion
        dbu_rect = [int(coord * DBU_PER_MICRON) for coord in config['rect_um']]
        
        # Layer creation
        layer_idx = layout.layer(pya.LayerInfo(*config['layer']))
        print(f"{timestamp()} Created layer {config['layer']} ({config['comment']})")

        # Shape insertion
        box = pya.Box(*dbu_rect)
        for cell in layout.top_cells():
            cell.shapes(layer_idx).insert(box)
        print(f"{timestamp()} Added rectangle: {config['rect_um']}μm")

def process_layout():
    """Main processing workflow"""
    try:
        layout = pya.Layout()
        
        # Load input
        print(f"{timestamp()} Loading: {INPUT_FILE}")
        layout.read(INPUT_FILE)
        
        # Layer operations
        print(f"\n{timestamp()} Layer deletion started")
        del_count = delete_target_layers(layout)
        print(f"{timestamp()} Total layers deleted: {del_count}/{len(DELETE_LAYERS)}")

        print(f"\n{timestamp()} Layer creation started")
        create_new_layers(layout)

        # Save output
        print(f"\n{timestamp()} Writing: {OUTPUT_FILE}")
        layout.write(OUTPUT_FILE)
        return True

    except Exception as e:
        print(f"{timestamp()} Error: {str(e)}")
        return False

if __name__ == "__main__":
    print(f"{timestamp()} Process initiated")
    if process_layout():
        print(f"\n{timestamp()} Successfully completed")
    else:
        print(f"\n{timestamp()} Process terminated with errors")
