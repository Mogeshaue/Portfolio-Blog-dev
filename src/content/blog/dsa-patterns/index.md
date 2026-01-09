---
title: Dsa Patterns
date: "2026-01-09"
draft: false
summary: This is an pattern template file for the DSA concepts
tags: ["DSA", "patterns"]
---

# 🎯 DSA Interview Patterns - Master Guide

## 🔍 Pattern Recognition Cheat Sheet

### When to Use Which Pattern?

| **Keywords/Hints in Problem** | **Pattern to Use** |
|------------------------------|-------------------|
| "Sorted array/list" | Binary Search, Two Pointers |
| "Pair/triplet with target sum" | Two Pointers, Hash Map |
| "Subarray/substring" | Sliding Window |
| "Maximum/minimum window" | Sliding Window |
| "Consecutive elements" | Sliding Window |
| "Linked list cycle" | Fast & Slow Pointers |
| "Middle of linked list" | Fast & Slow Pointers |
| "Overlapping intervals" | Merge Intervals |
| "Find missing/duplicate in range" | Cyclic Sort |
| "Level-order traversal" | BFS (Queue) |
| "Path in tree" | DFS (Recursion/Stack) |
| "All paths/permutations" | Backtracking |
| "All subsets/combinations" | Backtracking/Subsets |
| "Top/Bottom/Kth element" | Heap/Quick Select |
| "Frequency count" | Hash Map |
| "Anagram/palindrome" | Hash Map/Two Pointers |
| "Optimize previous solution" | Dynamic Programming |
| "Connected components" | Graph BFS/DFS/Union Find |
| "Shortest path" | BFS (unweighted), Dijkstra |
| "Dependency/ordering" | Topological Sort |
| "Next greater/smaller" | Monotonic Stack |
| "Range sum queries" | Prefix Sum |
| "Auto-complete/spell checker" | Trie |

---

## 📚 Complete Pattern Templates

### 1. **Two Pointers Pattern**
**When to use:** Sorted arrays, finding pairs, palindromes, removing duplicates

```python
# Template: Two Pointers (opposite ends)
def two_pointers_opposite(arr):
    left, right = 0, len(arr) - 1
    
    while left < right:
        # Process current pair
        current_sum = arr[left] + arr[right]
        
        if condition_met:
            # Process result
            return result
        elif need_smaller:
            right -= 1
        else:
            left += 1
    
    return result

# Template: Two Pointers (same direction)
def two_pointers_same_direction(arr):
    slow, fast = 0, 0
    
    for fast in range(len(arr)):
        if condition_met:
            # Process arr[fast]
            arr[slow] = arr[fast]
            slow += 1
    
    return slow
```

### 2. **Sliding Window Pattern**
**When to use:** Subarray/substring problems, consecutive elements, window size

```python
# Fixed Size Window
def fixed_window(arr, k):
    window_sum = sum(arr[:k])
    max_sum = window_sum
    
    for i in range(k, len(arr)):
        window_sum = window_sum - arr[i-k] + arr[i]
        max_sum = max(max_sum, window_sum)
    
    return max_sum

# Variable Size Window
def variable_window(s, condition):
    left = 0
    window = {}  # or any data structure
    result = 0
    
    for right in range(len(s)):
        # Add right element to window
        window[s[right]] = window.get(s[right], 0) + 1
        
        # Shrink window if invalid
        while not_valid_window:
            window[s[left]] -= 1
            if window[s[left]] == 0:
                del window[s[left]]
            left += 1
        
        # Update result
        result = max(result, right - left + 1)
    
    return result
```

### 3. **Fast & Slow Pointers Pattern**
**When to use:** Cycle detection, middle element, palindrome in linked list

```python
# Cycle Detection
def has_cycle(head):
    slow = fast = head
    
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        
        if slow == fast:
            return True
    
    return False

# Find Middle
def find_middle(head):
    slow = fast = head
    
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
    
    return slow
```

### 4. **Merge Intervals Pattern**
**When to use:** Overlapping intervals, meeting rooms, interval intersections

```python
def merge_intervals(intervals):
    if not intervals:
        return []
    
    intervals.sort(key=lambda x: x[0])
    merged = [intervals[0]]
    
    for current in intervals[1:]:
        last = merged[-1]
        
        if current[0] <= last[1]:  # Overlapping
            merged[-1] = [last[0], max(last[1], current[1])]
        else:
            merged.append(current)
    
    return merged
```

### 5. **Cyclic Sort Pattern**
**When to use:** Problems with numbers in range [1, n], finding missing/duplicate

```python
def cyclic_sort(nums):
    i = 0
    while i < len(nums):
        correct_idx = nums[i] - 1  # For 1 to n range
        
        if nums[i] != nums[correct_idx]:
            nums[i], nums[correct_idx] = nums[correct_idx], nums[i]
        else:
            i += 1
    
    # Find missing/duplicate
    for i in range(len(nums)):
        if nums[i] != i + 1:
            return i + 1  # Missing number
    
    return len(nums) + 1
```

### 6. **Tree BFS Pattern**
**When to use:** Level order traversal, minimum depth, level averages

```python
from collections import deque

def tree_bfs(root):
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        current_level = []
        
        for _ in range(level_size):
            node = queue.popleft()
            current_level.append(node.val)
            
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        
        result.append(current_level)
    
    return result
```

### 7. **Tree DFS Pattern**
**When to use:** Path sum, all paths, diameter, serialize tree

```python
# Preorder DFS
def dfs_preorder(root):
    if not root:
        return
    
    # Process current node
    print(root.val)
    dfs_preorder(root.left)
    dfs_preorder(root.right)

# Path Sum Pattern
def has_path_sum(root, target_sum):
    if not root:
        return False
    
    if not root.left and not root.right:  # Leaf node
        return root.val == target_sum
    
    target_sum -= root.val
    return (has_path_sum(root.left, target_sum) or 
            has_path_sum(root.right, target_sum))

# All Paths Pattern
def all_paths(root):
    def dfs(node, path, result):
        if not node:
            return
        
        path.append(node.val)
        
        if not node.left and not node.right:
            result.append(path[:])
        else:
            dfs(node.left, path, result)
            dfs(node.right, path, result)
        
        path.pop()  # Backtrack
    
    result = []
    dfs(root, [], result)
    return result
```

### 8. **Heap Pattern**
**When to use:** Top K elements, K closest points, median of stream

```python
import heapq

# Top K Elements
def top_k_elements(nums, k):
    min_heap = []
    
    for num in nums:
        heapq.heappush(min_heap, num)
        if len(min_heap) > k:
            heapq.heappop(min_heap)
    
    return min_heap

# K Closest Points
def k_closest(points, k):
    max_heap = []
    
    for x, y in points:
        dist = -(x*x + y*y)
        
        if len(max_heap) < k:
            heapq.heappush(max_heap, (dist, [x, y]))
        elif dist > max_heap[0][0]:
            heapq.heappushpop(max_heap, (dist, [x, y]))
    
    return [point for _, point in max_heap]
```

### 9. **Backtracking Pattern**
**When to use:** Subsets, permutations, combinations, N-Queens, Sudoku

```python
# Subsets
def subsets(nums):
    def backtrack(start, path):
        result.append(path[:])
        
        for i in range(start, len(nums)):
            path.append(nums[i])
            backtrack(i + 1, path)
            path.pop()
    
    result = []
    backtrack(0, [])
    return result

# Permutations
def permutations(nums):
    def backtrack(path):
        if len(path) == len(nums):
            result.append(path[:])
            return
        
        for num in nums:
            if num in path:
                continue
            path.append(num)
            backtrack(path)
            path.pop()
    
    result = []
    backtrack([])
    return result

# Combinations
def combinations(n, k):
    def backtrack(start, path):
        if len(path) == k:
            result.append(path[:])
            return
        
        for i in range(start, n + 1):
            path.append(i)
            backtrack(i + 1, path)
            path.pop()
    
    result = []
    backtrack(1, [])
    return result
```

### 10. **Binary Search Pattern**
**When to use:** Sorted array, search in rotated array, find peak element

```python
# Standard Binary Search
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1

# Binary Search on Answer
def binary_search_answer(condition_func, min_val, max_val):
    left, right = min_val, max_val
    result = -1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if condition_func(mid):
            result = mid
            right = mid - 1  # Try for better answer
        else:
            left = mid + 1
    
    return result
```

### 11. **Graph BFS/DFS Pattern**
**When to use:** Connected components, shortest path, islands, clone graph

```python
from collections import deque

# Graph BFS
def graph_bfs(graph, start):
    visited = set([start])
    queue = deque([start])
    
    while queue:
        node = queue.popleft()
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    
    return visited

# Graph DFS
def graph_dfs(graph, start):
    visited = set()
    
    def dfs(node):
        visited.add(node)
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                dfs(neighbor)
    
    dfs(start)
    return visited

# Number of Islands (Grid DFS)
def num_islands(grid):
    def dfs(i, j):
        if (i < 0 or i >= len(grid) or 
            j < 0 or j >= len(grid[0]) or 
            grid[i][j] != '1'):
            return
        
        grid[i][j] = '0'  # Mark as visited
        
        # Check all 4 directions
        dfs(i+1, j)
        dfs(i-1, j)
        dfs(i, j+1)
        dfs(i, j-1)
    
    count = 0
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == '1':
                dfs(i, j)
                count += 1
    
    return count
```

### 12. **Dynamic Programming Pattern**
**When to use:** Optimization problems, counting problems, decision problems

```python
# 1D DP - Fibonacci/Climbing Stairs
def fibonacci(n):
    if n <= 1:
        return n
    
    dp = [0, 1]
    
    for i in range(2, n + 1):
        dp.append(dp[i-1] + dp[i-2])
        # Space optimization: dp[i%2] = dp[(i-1)%2] + dp[(i-2)%2]
    
    return dp[n]

# 2D DP - Longest Common Subsequence
def lcs(text1, text2):
    m, n = len(text1), len(text2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if text1[i-1] == text2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    
    return dp[m][n]

# Knapsack Pattern
def knapsack(weights, values, capacity):
    n = len(weights)
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]
    
    for i in range(1, n + 1):
        for w in range(1, capacity + 1):
            if weights[i-1] <= w:
                dp[i][w] = max(
                    dp[i-1][w],
                    values[i-1] + dp[i-1][w - weights[i-1]]
                )
            else:
                dp[i][w] = dp[i-1][w]
    
    return dp[n][capacity]
```

### 13. **Topological Sort Pattern**
**When to use:** Course schedule, task ordering, dependency resolution

```python
from collections import deque, defaultdict

def topological_sort(num_nodes, prerequisites):
    # Build graph and indegree
    graph = defaultdict(list)
    indegree = [0] * num_nodes
    
    for course, prereq in prerequisites:
        graph[prereq].append(course)
        indegree[course] += 1
    
    # BFS with queue
    queue = deque([i for i in range(num_nodes) if indegree[i] == 0])
    result = []
    
    while queue:
        node = queue.popleft()
        result.append(node)
        
        for neighbor in graph[node]:
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0:
                queue.append(neighbor)
    
    return result if len(result) == num_nodes else []
```

### 14. **Union Find Pattern**
**When to use:** Connected components, detect cycle in graph, accounts merge

```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # Path compression
        return self.parent[x]
    
    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        
        if px == py:
            return False
        
        # Union by rank
        if self.rank[px] < self.rank[py]:
            self.parent[px] = py
        elif self.rank[px] > self.rank[py]:
            self.parent[py] = px
        else:
            self.parent[py] = px
            self.rank[px] += 1
        
        return True
    
    def connected(self, x, y):
        return self.find(x) == self.find(y)
```

### 15. **Monotonic Stack Pattern**
**When to use:** Next greater element, daily temperatures, largest rectangle

```python
# Next Greater Element
def next_greater_element(nums):
    stack = []
    result = [-1] * len(nums)
    
    for i, num in enumerate(nums):
        while stack and nums[stack[-1]] < num:
            idx = stack.pop()
            result[idx] = num
        stack.append(i)
    
    return result

# Largest Rectangle in Histogram
def largest_rectangle(heights):
    stack = []
    max_area = 0
    
    for i, h in enumerate(heights):
        while stack and heights[stack[-1]] > h:
            height = heights[stack.pop()]
            width = i if not stack else i - stack[-1] - 1
            max_area = max(max_area, height * width)
        stack.append(i)
    
    while stack:
        height = heights[stack.pop()]
        width = len(heights) if not stack else len(heights) - stack[-1] - 1
        max_area = max(max_area, height * width)
    
    return max_area
```

### 16. **Prefix Sum Pattern**
**When to use:** Range sum queries, subarray sum equals K

```python
# Basic Prefix Sum
def prefix_sum(nums):
    prefix = [0]
    for num in nums:
        prefix.append(prefix[-1] + num)
    return prefix

# Subarray Sum Equals K
def subarray_sum(nums, k):
    count = 0
    prefix_sum = 0
    sum_freq = {0: 1}
    
    for num in nums:
        prefix_sum += num
        
        if prefix_sum - k in sum_freq:
            count += sum_freq[prefix_sum - k]
        
        sum_freq[prefix_sum] = sum_freq.get(prefix_sum, 0) + 1
    
    return count
```

### 17. **Trie Pattern**
**When to use:** Word search, auto-complete, spell checker

```python
class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_end = False

class Trie:
    def __init__(self):
        self.root = TrieNode()
    
    def insert(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end = True
    
    def search(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.is_end
    
    def starts_with(self, prefix):
        node = self.root
        for char in prefix:
            if char not in node.children:
                return False
            node = node.children[char]
        return True
```

---

## 🎯 Quick Decision Framework

1. **Array/String Problems:**
   - Sorted? → Binary Search, Two Pointers
   - Subarray/Substring? → Sliding Window
   - Frequency/Count? → Hash Map
   - Optimization? → DP or Greedy

2. **Tree/Graph Problems:**
   - Level-wise? → BFS
   - Path/All paths? → DFS
   - Shortest path? → BFS (unweighted), Dijkstra (weighted)
   - Dependencies? → Topological Sort

3. **Optimization Problems:**
   - Optimal substructure? → Dynamic Programming
   - Greedy choice works? → Greedy
   - Small constraints? → Backtracking

4. **Search Problems:**
   - All solutions? → Backtracking
   - Optimal solution? → BFS/DP
   - Yes/No? → DFS/BFS

---

## 💡 Pro Tips for Interviews

1. **Always clarify:**
   - Input constraints (size, range)
   - Edge cases (empty, single element, duplicates)
   - Expected time/space complexity

2. **Pattern Recognition Steps:**
   - Read problem twice
   - Identify keywords
   - Match with patterns above
   - Start with brute force, then optimize

3. **Common Optimizations:**
   - Use HashMap to reduce from O(n²) to O(n)
   - Sort array to enable Two Pointers/Binary Search
   - Use extra space to reduce time complexity
   - Consider preprocessing if multiple queries

4. **Practice Order:**
   - Start with: Two Pointers, Sliding Window, HashMap
   - Then: Tree DFS/BFS, Binary Search
   - Advanced: DP, Backtracking, Graph algorithms

Remember: **Pattern recognition comes with practice!** Solve 3-5 problems per pattern to build intuition.
