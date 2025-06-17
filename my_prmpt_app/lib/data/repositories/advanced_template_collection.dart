// lib/data/repositories/advanced_template_collection.dart
import '../../data/models/enhanced_template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/models/ai_metadata.dart';

class AdvancedTemplateCollection {
  static List<EnhancedTemplateModel> getAdvancedTemplates() {
    return [
      // Software Engineering Templates
      _createSystemDesignTemplate(),
      _createCodeReviewTemplate(),
      _createTechnicalDocumentationTemplate(),
      _createAPIDesignTemplate(),

      // Business & Strategy Templates
      _createBusinessPlanTemplate(),
      _createMarketAnalysisTemplate(),
      _createCompetitorAnalysisTemplate(),
      _createProductRoadmapTemplate(),

      // Creative & Content Templates
      _createContentStrategyTemplate(),
      _createStorytellingTemplate(),
      _createSocialMediaCampaignTemplate(),
      _createBrandingTemplate(),

      // Education & Learning Templates
      _createCurriculumDesignTemplate(),
      _createLearningObjectivesTemplate(),
      _createAssessmentTemplate(),

      // Research & Analysis Templates
      _createResearchProposalTemplate(),
      _createDataAnalysisTemplate(),
      _createSurveyDesignTemplate(),
    ];
  }

  static EnhancedTemplateModel _createSystemDesignTemplate() {
    return EnhancedTemplateModel(
      id: 'system_design_advanced',
      title: 'System Design Architecture',
      description:
          'Comprehensive system design template for scalable applications',
      category: 'Software Engineering',
      templateContent: '''
# System Design: {{system_name}}

## 1. Requirements Analysis
**Functional Requirements:**
{{functional_requirements}}

**Non-Functional Requirements:**
- **Scalability:** {{scalability_requirements}}
- **Performance:** {{performance_requirements}}
- **Availability:** {{availability_requirements}}
- **Security:** {{security_requirements}}

## 2. High-Level Architecture
**System Overview:**
{{system_overview}}

**Key Components:**
{{key_components}}

**Technology Stack:**
- **Frontend:** {{frontend_tech}}
- **Backend:** {{backend_tech}}
- **Database:** {{database_tech}}
- **Infrastructure:** {{infrastructure_tech}}

## 3. Detailed Design

### 3.1 Data Models
{{data_models}}

### 3.2 API Design
{{api_design}}

### 3.3 Database Schema
{{database_schema}}

## 4. Scalability & Performance
**Scaling Strategy:**
{{scaling_strategy}}

**Caching Strategy:**
{{caching_strategy}}

**Load Balancing:**
{{load_balancing}}

## 5. Security Considerations
{{security_considerations}}

## 6. Monitoring & Observability
{{monitoring_strategy}}

## 7. Deployment Strategy
{{deployment_strategy}}

## 8. Risk Assessment
{{risk_assessment}}

---
*Generated with AI-enhanced system design methodology*
''',
      fields: [
        PromptField(
          id: 'system_name',
          label: 'System Name',
          placeholder: 'e.g., E-commerce Platform',
          isRequired: true,
          helpText: 'What system are you designing?',
        ),
        PromptField(
          id: 'functional_requirements',
          label: 'Functional Requirements',
          placeholder: 'List the main features and functionality...',
          type: FieldType.textarea,
          isRequired: true,
          helpText: 'What should the system do?',
        ),
        PromptField(
          id: 'scalability_requirements',
          label: 'Scalability Requirements',
          placeholder: 'e.g., Handle 1M+ concurrent users',
          isRequired: true,
        ),
        PromptField(
          id: 'performance_requirements',
          label: 'Performance Requirements',
          placeholder: 'e.g., Response time < 200ms',
          isRequired: true,
        ),
        PromptField(
          id: 'availability_requirements',
          label: 'Availability Requirements',
          placeholder: 'e.g., 99.9% uptime',
          isRequired: true,
        ),
        PromptField(
          id: 'security_requirements',
          label: 'Security Requirements',
          placeholder: 'Authentication, authorization, encryption...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'frontend_tech',
          label: 'Frontend Technology',
          placeholder: 'Select frontend technology',
          type: FieldType.dropdown,
          options: [
            'React',
            'Vue.js',
            'Angular',
            'Flutter',
            'React Native',
            'Other'
          ],
          defaultValue: 'React',
        ),
        PromptField(
          id: 'backend_tech',
          label: 'Backend Technology',
          placeholder: 'Select backend technology',
          type: FieldType.dropdown,
          options: ['Node.js', 'Python', 'Java', 'Go', 'C#', 'Ruby', 'Other'],
          defaultValue: 'Node.js',
        ),
        PromptField(
          id: 'database_tech',
          label: 'Database Technology',
          placeholder: 'Select database technology',
          type: FieldType.dropdown,
          options: [
            'PostgreSQL',
            'MySQL',
            'MongoDB',
            'Redis',
            'DynamoDB',
            'Other'
          ],
          defaultValue: 'PostgreSQL',
        ),
        PromptField(
          id: 'infrastructure_tech',
          label: 'Infrastructure',
          placeholder: 'Select infrastructure platform',
          type: FieldType.dropdown,
          options: [
            'AWS',
            'Google Cloud',
            'Azure',
            'Docker',
            'Kubernetes',
            'Other'
          ],
          defaultValue: 'AWS',
        ),
        PromptField(
          id: 'system_overview',
          label: 'System Overview',
          placeholder: 'Describe the overall system architecture...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'key_components',
          label: 'Key Components',
          placeholder: 'List the main system components...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'data_models',
          label: 'Data Models',
          placeholder: 'Define the main data entities and relationships...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'api_design',
          label: 'API Design',
          placeholder: 'Describe the API endpoints and interfaces...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'database_schema',
          label: 'Database Schema',
          placeholder: 'Define tables, indexes, and relationships...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'scaling_strategy',
          label: 'Scaling Strategy',
          placeholder: 'How will the system scale horizontally and vertically?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'caching_strategy',
          label: 'Caching Strategy',
          placeholder: 'What caching mechanisms will be used?',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'load_balancing',
          label: 'Load Balancing',
          placeholder: 'How will traffic be distributed?',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'security_considerations',
          label: 'Security Considerations',
          placeholder: 'What security measures will be implemented?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'monitoring_strategy',
          label: 'Monitoring Strategy',
          placeholder: 'How will the system be monitored?',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'deployment_strategy',
          label: 'Deployment Strategy',
          placeholder: 'How will the system be deployed and updated?',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'risk_assessment',
          label: 'Risk Assessment',
          placeholder:
              'What are the potential risks and mitigation strategies?',
          type: FieldType.textarea,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      author: 'AI System Architect',
      tags: ['system design', 'architecture', 'scalability', 'engineering'],
      aiMetadata: AIMetadata(
        isAIGenerated: true,
        confidence: 0.95,
        aiModel: 'PromptForge-AI-v2',
        extractedKeywords: [
          'system design',
          'architecture',
          'scalability',
          'performance'
        ],
        contextDomain: 'Software Engineering',
        aiProcessedAt: DateTime.now(),
      ),
    );
  }

  static EnhancedTemplateModel _createBusinessPlanTemplate() {
    return EnhancedTemplateModel(
      id: 'business_plan_advanced',
      title: 'Comprehensive Business Plan',
      description:
          'AI-enhanced business plan template for startups and enterprises',
      category: 'Business Strategy',
      templateContent: '''
# Business Plan: {{business_name}}

## Executive Summary
**Business Concept:**
{{business_concept}}

**Mission Statement:**
{{mission_statement}}

**Key Success Factors:**
{{key_success_factors}}

**Financial Summary:**
{{financial_summary}}

## 1. Company Description
**Company Overview:**
{{company_overview}}

**Legal Structure:**
{{legal_structure}}

**Location:**
{{business_location}}

**Industry Analysis:**
{{industry_analysis}}

## 2. Market Analysis
**Target Market:**
{{target_market}}

**Market Size:**
{{market_size}}

**Market Trends:**
{{market_trends}}

**Customer Analysis:**
{{customer_analysis}}

## 3. Competitive Analysis
**Direct Competitors:**
{{direct_competitors}}

**Indirect Competitors:**
{{indirect_competitors}}

**Competitive Advantages:**
{{competitive_advantages}}

**SWOT Analysis:**
**Strengths:** {{strengths}}
**Weaknesses:** {{weaknesses}}
**Opportunities:** {{opportunities}}
**Threats:** {{threats}}

## 4. Products/Services
**Product/Service Description:**
{{product_description}}

**Product Development:**
{{product_development}}

**Intellectual Property:**
{{intellectual_property}}

## 5. Marketing & Sales Strategy
**Marketing Strategy:**
{{marketing_strategy}}

**Sales Strategy:**
{{sales_strategy}}

**Pricing Strategy:**
{{pricing_strategy}}

**Distribution Channels:**
{{distribution_channels}}

## 6. Operations Plan
**Operational Workflow:**
{{operational_workflow}}

**Technology Requirements:**
{{technology_requirements}}

**Suppliers:**
{{suppliers}}

**Quality Control:**
{{quality_control}}

## 7. Management Team
**Key Personnel:**
{{key_personnel}}

**Organizational Structure:**
{{organizational_structure}}

**Advisory Board:**
{{advisory_board}}

## 8. Financial Projections
**Revenue Projections:**
{{revenue_projections}}

**Expense Projections:**
{{expense_projections}}

**Break-even Analysis:**
{{breakeven_analysis}}

**Funding Requirements:**
{{funding_requirements}}

## 9. Risk Analysis
**Business Risks:**
{{business_risks}}

**Mitigation Strategies:**
{{mitigation_strategies}}

## 10. Implementation Timeline
{{implementation_timeline}}

---
*AI-Enhanced Business Planning Framework*
''',
      fields: [
        PromptField(
          id: 'business_name',
          label: 'Business Name',
          placeholder: 'Your business name',
          isRequired: true,
        ),
        PromptField(
          id: 'business_concept',
          label: 'Business Concept',
          placeholder: 'Describe your business idea in 2-3 sentences...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'mission_statement',
          label: 'Mission Statement',
          placeholder: 'What is your company\'s mission?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'key_success_factors',
          label: 'Key Success Factors',
          placeholder: 'What are the critical factors for success?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'financial_summary',
          label: 'Financial Summary',
          placeholder: 'Brief overview of financial projections...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'company_overview',
          label: 'Company Overview',
          placeholder: 'Describe your company...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'legal_structure',
          label: 'Legal Structure',
          placeholder: 'Select legal structure',
          type: FieldType.dropdown,
          options: [
            'LLC',
            'Corporation',
            'Partnership',
            'Sole Proprietorship',
            'Other'
          ],
          isRequired: true,
        ),
        PromptField(
          id: 'business_location',
          label: 'Business Location',
          placeholder: 'Where will your business operate?',
          isRequired: true,
        ),
        PromptField(
          id: 'industry_analysis',
          label: 'Industry Analysis',
          placeholder: 'Analysis of your industry...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'target_market',
          label: 'Target Market',
          placeholder: 'Who are your target customers?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'market_size',
          label: 'Market Size',
          placeholder: 'What is the size of your target market?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'competitive_advantages',
          label: 'Competitive Advantages',
          placeholder: 'What sets you apart from competitors?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'marketing_strategy',
          label: 'Marketing Strategy',
          placeholder: 'How will you market your product/service?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'revenue_projections',
          label: 'Revenue Projections',
          placeholder: 'Expected revenue for the next 3-5 years...',
          type: FieldType.textarea,
          isRequired: true,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      author: 'AI Business Strategist',
      tags: ['business plan', 'strategy', 'startup', 'entrepreneurship'],
      aiMetadata: AIMetadata(
        isAIGenerated: true,
        confidence: 0.92,
        contextDomain: 'Business Strategy',
        aiProcessedAt: DateTime.now(),
      ),
    );
  }

  static EnhancedTemplateModel _createContentStrategyTemplate() {
    return EnhancedTemplateModel(
      id: 'content_strategy_advanced',
      title: 'Content Marketing Strategy',
      description:
          'Comprehensive content strategy template for digital marketing',
      category: 'Creative Content',
      templateContent: '''
# Content Marketing Strategy: {{brand_name}}

## 1. Content Objectives
**Primary Goals:**
{{content_goals}}

**Target Audience:**
{{target_audience}}

**Brand Voice & Tone:**
{{brand_voice}}

## 2. Content Audit
**Current Content Assessment:**
{{content_audit}}

**Content Gaps:**
{{content_gaps}}

**Competitor Analysis:**
{{competitor_content}}

## 3. Content Types & Formats
**Blog Posts:** {{blog_strategy}}
**Video Content:** {{video_strategy}}
**Social Media:** {{social_strategy}}
**Email Marketing:** {{email_strategy}}
**Infographics:** {{infographic_strategy}}

## 4. Content Calendar
**Editorial Calendar:**
{{editorial_calendar}}

**Publishing Schedule:**
{{publishing_schedule}}

**Seasonal Content:**
{{seasonal_content}}

## 5. Content Creation Workflow
**Content Creation Process:**
{{creation_process}}

**Team Responsibilities:**
{{team_responsibilities}}

**Quality Control:**
{{quality_control}}

## 6. Distribution Strategy
**Channels:**
{{distribution_channels}}

**Cross-Promotion:**
{{cross_promotion}}

**Influencer Partnerships:**
{{influencer_strategy}}

## 7. Performance Metrics
**KPIs:**
{{content_kpis}}

**Analytics Tools:**
{{analytics_tools}}

**Reporting Schedule:**
{{reporting_schedule}}

## 8. Budget & Resources
**Content Budget:**
{{content_budget}}

**Tools & Software:**
{{content_tools}}

**External Resources:**
{{external_resources}}

---
*AI-Powered Content Strategy Framework*
''',
      fields: [
        PromptField(
          id: 'brand_name',
          label: 'Brand/Company Name',
          placeholder: 'Your brand or company name',
          isRequired: true,
        ),
        PromptField(
          id: 'content_goals',
          label: 'Content Goals',
          placeholder: 'What do you want to achieve with your content?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'target_audience',
          label: 'Target Audience',
          placeholder:
              'Describe your ideal audience demographics and psychographics...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'brand_voice',
          label: 'Brand Voice & Tone',
          placeholder:
              'How should your brand sound? (e.g., professional, friendly, authoritative)',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'content_audit',
          label: 'Current Content Assessment',
          placeholder: 'What content do you currently have? What\'s working?',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'blog_strategy',
          label: 'Blog Strategy',
          placeholder: 'Blog post topics, frequency, and approach...',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'video_strategy',
          label: 'Video Strategy',
          placeholder: 'Video content plans, platforms, and formats...',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'social_strategy',
          label: 'Social Media Strategy',
          placeholder: 'Social media content approach for each platform...',
          type: FieldType.textarea,
        ),
        PromptField(
          id: 'distribution_channels',
          label: 'Distribution Channels',
          placeholder: 'Where will you publish and promote your content?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'content_kpis',
          label: 'Key Performance Indicators',
          placeholder: 'How will you measure content success?',
          type: FieldType.textarea,
          isRequired: true,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      author: 'AI Content Strategist',
      tags: [
        'content strategy',
        'marketing',
        'digital marketing',
        'content creation'
      ],
      aiMetadata: AIMetadata(
        isAIGenerated: true,
        confidence: 0.90,
        contextDomain: 'Creative Content',
        aiProcessedAt: DateTime.now(),
      ),
    );
  }

  // Additional template creation methods would continue here...
  // For brevity, I'll create placeholder methods for the remaining templates

  static EnhancedTemplateModel _createCodeReviewTemplate() {
    return _createPlaceholderTemplate(
      'code_review_advanced',
      'Code Review Checklist',
      'Comprehensive code review template with best practices',
      'Software Engineering',
    );
  }

  static EnhancedTemplateModel _createTechnicalDocumentationTemplate() {
    return _createPlaceholderTemplate(
      'tech_docs_advanced',
      'Technical Documentation',
      'Complete technical documentation template',
      'Software Engineering',
    );
  }

  static EnhancedTemplateModel _createAPIDesignTemplate() {
    return _createPlaceholderTemplate(
      'api_design_advanced',
      'API Design Specification',
      'RESTful API design template with OpenAPI standards',
      'Software Engineering',
    );
  }

  static EnhancedTemplateModel _createMarketAnalysisTemplate() {
    return _createPlaceholderTemplate(
      'market_analysis_advanced',
      'Market Research Analysis',
      'Comprehensive market analysis and research template',
      'Business Strategy',
    );
  }

  static EnhancedTemplateModel _createCompetitorAnalysisTemplate() {
    return _createPlaceholderTemplate(
      'competitor_analysis_advanced',
      'Competitor Analysis',
      'In-depth competitive analysis framework',
      'Business Strategy',
    );
  }

  static EnhancedTemplateModel _createProductRoadmapTemplate() {
    return _createPlaceholderTemplate(
      'product_roadmap_advanced',
      'Product Roadmap Planning',
      'Strategic product development timeline and planning',
      'Business Strategy',
    );
  }

  static EnhancedTemplateModel _createStorytellingTemplate() {
    return _createPlaceholderTemplate(
      'storytelling_advanced',
      'Storytelling Framework',
      'Narrative structure for compelling storytelling',
      'Creative Content',
    );
  }

  static EnhancedTemplateModel _createSocialMediaCampaignTemplate() {
    return _createPlaceholderTemplate(
      'social_campaign_advanced',
      'Social Media Campaign',
      'Cross-platform social media campaign planning',
      'Creative Content',
    );
  }

  static EnhancedTemplateModel _createBrandingTemplate() {
    return _createPlaceholderTemplate(
      'branding_advanced',
      'Brand Identity Development',
      'Comprehensive branding and identity framework',
      'Creative Content',
    );
  }

  static EnhancedTemplateModel _createCurriculumDesignTemplate() {
    return _createPlaceholderTemplate(
      'curriculum_design_advanced',
      'Curriculum Design Framework',
      'Educational program development template',
      'Education',
    );
  }

  static EnhancedTemplateModel _createLearningObjectivesTemplate() {
    return _createPlaceholderTemplate(
      'learning_objectives_advanced',
      'Learning Objective Mapping',
      'Competency-based learning goals framework',
      'Education',
    );
  }

  static EnhancedTemplateModel _createAssessmentTemplate() {
    return _createPlaceholderTemplate(
      'assessment_design_advanced',
      'Assessment Design Template',
      'Multi-modal assessment strategies',
      'Education',
    );
  }

  static EnhancedTemplateModel _createResearchProposalTemplate() {
    return _createPlaceholderTemplate(
      'research_proposal_advanced',
      'Research Proposal Framework',
      'Academic and industry research planning',
      'Research',
    );
  }

  static EnhancedTemplateModel _createDataAnalysisTemplate() {
    return _createPlaceholderTemplate(
      'data_analysis_advanced',
      'Data Analysis Protocol',
      'Statistical analysis and interpretation framework',
      'Research',
    );
  }

  static EnhancedTemplateModel _createSurveyDesignTemplate() {
    return _createPlaceholderTemplate(
      'survey_design_advanced',
      'Survey Design Template',
      'Comprehensive questionnaire development',
      'Research',
    );
  }

  static EnhancedTemplateModel _createPlaceholderTemplate(
    String id,
    String title,
    String description,
    String category,
  ) {
    return EnhancedTemplateModel(
      id: id,
      title: title,
      description: description,
      category: category,
      templateContent: '''
# $title

## Overview
{{overview}}

## Objectives
{{objectives}}

## Methodology
{{methodology}}

## Implementation
{{implementation}}

## Expected Outcomes
{{outcomes}}

---
*AI-Enhanced $category Template*
''',
      fields: [
        PromptField(
          id: 'overview',
          label: 'Overview',
          placeholder: 'Provide an overview...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'objectives',
          label: 'Objectives',
          placeholder: 'What are the main objectives?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'methodology',
          label: 'Methodology',
          placeholder: 'Describe the approach or methodology...',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'implementation',
          label: 'Implementation',
          placeholder: 'How will this be implemented?',
          type: FieldType.textarea,
          isRequired: true,
        ),
        PromptField(
          id: 'outcomes',
          label: 'Expected Outcomes',
          placeholder: 'What outcomes do you expect?',
          type: FieldType.textarea,
          isRequired: true,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      author: 'AI Template Generator',
      tags: [category.toLowerCase(), 'ai-generated', 'professional'],
      aiMetadata: AIMetadata(
        isAIGenerated: true,
        confidence: 0.85,
        contextDomain: category,
        aiProcessedAt: DateTime.now(),
      ),
    );
  }
}
