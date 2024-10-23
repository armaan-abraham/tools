import gc
import torch
import gc
import torch
from typing import Dict, List
import gc
from IPython.display import display
import pandas as pd
import inspect
import traceback

# TODO: clean this up

def simple_referrer_check(tensor):
    """
    Very simple referrer check that avoids any tensor operations.
    """
    print(f"\nChecking referrers for tensor with id: {id(tensor)}")
    
    referrers = gc.get_referrers(tensor)
    print(f"Found {len(referrers)} referrers")
    
    for ref in referrers:
        print(f"\nReferrer type: {type(ref).__name__}")
        
        if isinstance(ref, dict):
            # Just count how many items in dict contain the tensor
            count = sum(1 for v in ref.values() if v is tensor)
            print(f"Dictionary has {len(ref)} total items and {count} direct references to tensor")
            
            # Try to identify if it's a special dictionary
            try:
                if ref is globals():
                    print("This is the globals() dictionary")
                shell = get_ipython()
                if ref is shell.user_ns:
                    print("This is IPython's user namespace")
            except:
                pass
        
        elif isinstance(ref, list):
            print(f"List with length {len(ref)}")
def get_referrer_info(obj) -> str:
    """
    Get information about objects referring to the tensor.
    Returns a formatted string with referrer details.
    """
    referrers = gc.get_referrers(obj)
    referrer_info = []
    
    for ref in referrers:
        # Skip frame objects and the function itself
        # if isinstance(ref, dict) or isinstance(ref, frame):
        #     continue
            
        try:
            # Get the type of referrer
            ref_type = type(ref).__name__
            
            # If it's a function or method, get its name and location
            if inspect.isfunction(ref) or inspect.ismethod(ref):
                ref_info = f"{ref.__name__} ({ref.__module__})"
            # If it's a class instance, get the class name
            elif hasattr(ref, '__class__'):
                ref_info = f"{ref.__class__.__name__}"
                # Try to get variable name if it's in a class
                try:
                    for name, value in inspect.getmembers(ref):
                        if value is obj and not name.startswith('_'):
                            ref_info += f".{name}"
                            break
                except:
                    pass
            else:
                ref_info = str(ref)
            
            # Try to get the file and line number
            try:
                frame_info = inspect.getframeinfo(inspect.currentframe().f_back)
                ref_info += f" at {frame_info.filename}:{frame_info.lineno}"
            except:
                pass
                
            referrer_info.append(ref_info)
        except:
            referrer_info.append(f"<unknown referrer of type {type(ref).__name__}>")
    
    return "\n".join(referrer_info) if referrer_info else "No accessible referrers"

def inspect_tensors() -> None:
    """
    Inspect all PyTorch tensors in memory along with their memory usage.
    Displays a sorted table of tensors by memory usage.
    """
    # Collect all tensors
    tensor_info: List[Dict] = []
    total_memory = 0
    
    # Force garbage collection to get accurate memory stats
    gc.collect()
    
    # Iterate through all objects in memory
    for obj in gc.get_objects():
        try:
            if torch.is_tensor(obj):
                # Get tensor details
                tensor_size = obj.element_size() * obj.nelement()
                total_memory += tensor_size
                
                tensor_info.append({
                    'Shape': str(tuple(obj.shape)),
                    'Dtype': str(obj.dtype),
                    'Device': str(obj.device),
                    'Size (MB)': tensor_size / (1024 * 1024),
                    'Requires Grad': obj.requires_grad,
                    'Elements': obj.nelement(),
                    'Contiguous': obj.is_contiguous(),
                    'Object': obj,
                })
            elif hasattr(obj, 'data') and torch.is_tensor(obj.data):
                # Handle autograd Variables
                tensor_size = obj.data.element_size() * obj.data.nelement()
                total_memory += tensor_size
                
                tensor_info.append({
                    'Shape': str(tuple(obj.data.shape)),
                    'Dtype': str(obj.data.dtype),
                    'Device': str(obj.data.device),
                    'Size (MB)': tensor_size / (1024 * 1024),
                    'Requires Grad': obj.requires_grad,
                    'Elements': obj.data.nelement(),
                    'Contiguous': obj.data.is_contiguous(),
                    'Object': obj,
                })
        except Exception:
            # Skip any objects that can't be processed
            continue
    
    # Create DataFrame and sort by memory usage
    df = pd.DataFrame(tensor_info)
    if not df.empty:
        df = df.sort_values('Size (MB)', ascending=False)
        df['Size (MB)'] = df['Size (MB)'].round(2)
        
        print(f"\nTotal number of tensors: {len(tensor_info)}")
        print(f"Total memory usage: {(total_memory / (1024 * 1024)):.2f} MB")
        print("\nTensor Details:")
    else:
        print("No PyTorch tensors found in memory.")
    obj = df.iloc[3]['Object']
    df.drop(columns=['Object'], inplace=True)
    display(df)

    return obj
