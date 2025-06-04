import { describe, it, expect, beforeEach } from "vitest"

// Mock crop optimization contract
const mockCropContract = {
  cropPlans: new Map(),
  recommendations: new Map(),
  nextPlanId: 1,
  nextRecommendationId: 1,
}

function createCropPlan(farmerId, cropType, plantingDate, expectedHarvest, irrigationSchedule, fertilizerAmount) {
  const planId = mockCropContract.nextPlanId
  const plan = {
    farmerId,
    cropType,
    plantingDate,
    expectedHarvest,
    irrigationSchedule,
    fertilizerAmount,
    status: "active",
  }
  
  mockCropContract.cropPlans.set(planId, plan)
  mockCropContract.nextPlanId += 1
  
  return { success: planId }
}

function addRecommendation(farmerId, planId, recommendationType, description, priority) {
  const recommendationId = mockCropContract.nextRecommendationId
  const recommendation = {
    farmerId,
    planId,
    recommendationType,
    description,
    priority,
    createdAt: Date.now(),
  }
  
  mockCropContract.recommendations.set(recommendationId, recommendation)
  mockCropContract.nextRecommendationId += 1
  
  return { success: recommendationId }
}

function updatePlanStatus(planId, newStatus) {
  const plan = mockCropContract.cropPlans.get(planId)
  if (!plan) {
    return { error: 1 }
  }
  
  plan.status = newStatus
  mockCropContract.cropPlans.set(planId, plan)
  return { success: true }
}

function getCropPlan(planId) {
  return mockCropContract.cropPlans.get(planId) || null
}

function getRecommendation(recommendationId) {
  return mockCropContract.recommendations.get(recommendationId) || null
}

describe("Crop Optimization Contract", () => {
  beforeEach(() => {
    mockCropContract.cropPlans.clear()
    mockCropContract.recommendations.clear()
    mockCropContract.nextPlanId = 1
    mockCropContract.nextRecommendationId = 1
  })
  
  it("should create crop plan successfully", () => {
    const result = createCropPlan(1, "corn", 1640995200, 1648771200, 7, 50)
    
    expect(result.success).toBe(1)
    
    const plan = getCropPlan(1)
    expect(plan.farmerId).toBe(1)
    expect(plan.cropType).toBe("corn")
    expect(plan.status).toBe("active")
  })
  
  it("should add recommendation successfully", () => {
    createCropPlan(1, "wheat", 1640995200, 1648771200, 5, 30)
    const result = addRecommendation(1, 1, "irrigation", "Increase watering frequency", 1)
    
    expect(result.success).toBe(1)
    
    const recommendation = getRecommendation(1)
    expect(recommendation.recommendationType).toBe("irrigation")
    expect(recommendation.priority).toBe(1)
  })
  
  it("should update plan status successfully", () => {
    createCropPlan(1, "soybeans", 1640995200, 1648771200, 6, 40)
    const result = updatePlanStatus(1, "completed")
    
    expect(result.success).toBe(true)
    
    const plan = getCropPlan(1)
    expect(plan.status).toBe("completed")
  })
  
  it("should handle non-existent plan update", () => {
    const result = updatePlanStatus(999, "completed")
    expect(result.error).toBe(1)
  })
  
  it("should create multiple plans and recommendations", () => {
    createCropPlan(1, "corn", 1640995200, 1648771200, 7, 50)
    createCropPlan(2, "wheat", 1641081600, 1648857600, 5, 35)
    
    addRecommendation(1, 1, "fertilizer", "Reduce nitrogen application", 2)
    addRecommendation(2, 2, "pest-control", "Apply organic pesticide", 1)
    
    expect(mockCropContract.cropPlans.size).toBe(2)
    expect(mockCropContract.recommendations.size).toBe(2)
    
    const cornPlan = getCropPlan(1)
    const wheatPlan = getCropPlan(2)
    
    expect(cornPlan.cropType).toBe("corn")
    expect(wheatPlan.cropType).toBe("wheat")
  })
})
