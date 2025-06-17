import 'dart:convert';

/// Collection of research-oriented templates
class ResearchTemplates {
  /// Get all research templates
  static List<Map<String, dynamic>> getAll() {
    return [
      experimentDesignTemplate,
      literatureReviewTemplate,
      researchProtocolTemplate,
      dataAnalysisTemplate,
      userResearchTemplate,
      hypothesisTestingTemplate,
      researchEthicsTemplate,
    ];
  }

  /// Experiment Design Template
  static final Map<String, dynamic> experimentDesignTemplate = {
    "id": "experiment_design_framework",
    "title": "Scientific Experiment Design Framework",
    "description": "Comprehensive template for designing controlled scientific experiments across disciplines",
    "category": "Research Methods",
    "domain": "research",
    "templateContent": '''# Experiment Design Framework

## 1. Research Question and Hypotheses
**Primary Research Question:** {{research_question}}

**Hypotheses:**
- H0 (Null): {{null_hypothesis}}
- H1 (Alternative): {{alternative_hypothesis}}

**Variables:**
- Independent Variable(s): {{independent_variables}}
- Dependent Variable(s): {{dependent_variables}}
- Control Variables: {{control_variables}}

## 2. Experimental Design
**Design Type:** {{design_type}}

**Justification for Design Choice:** {{design_justification}}

**Sampling Method:** {{sampling_method}}

**Sample Size:** {{sample_size}}
**Justification for Sample Size:** {{sample_size_justification}}

**Randomization Procedure:** {{randomization_procedure}}

**Blinding Protocol:** {{blinding_protocol}}

## 3. Experimental Procedures
**Materials Required:** {{materials_list}}

**Equipment Setup:** {{equipment_setup}}

**Procedure Steps:**
{{procedure_steps}}

**Measurement Techniques:** {{measurement_techniques}}

**Quality Control Measures:** {{quality_control}}

## 4. Data Collection
**Data Collection Methods:** {{data_collection_methods}}

**Data Collection Schedule:** {{data_collection_schedule}}

**Data Recording Protocols:** {{data_recording_protocols}}

**Sample Data Collection Form:**
{{data_collection_form}}

## 5. Data Analysis Plan
**Statistical Methods:** {{statistical_methods}}

**Software Used:** {{analysis_software}}

**Data Preprocessing Steps:** {{preprocessing_steps}}

**Significance Threshold:** {{significance_threshold}}

**Effect Size Calculations:** {{effect_size}}

## 6. Validity Considerations
**Internal Validity Threats:** {{internal_validity_threats}}
**Mitigation Strategies:** {{internal_validity_mitigation}}

**External Validity Considerations:** {{external_validity}}
**Mitigation Strategies:** {{external_validity_mitigation}}

**Construct Validity Considerations:** {{construct_validity}}

## 7. Ethical Considerations
**IRB/Ethics Approval:** {{ethics_approval}}

**Informed Consent Process:** {{informed_consent}}

**Potential Risks to Participants:** {{participant_risks}}
**Risk Mitigation Plan:** {{risk_mitigation}}

**Data Privacy and Security Measures:** {{data_privacy}}

## 8. Timeline and Resources
**Project Timeline:** {{project_timeline}}

**Resource Requirements:** {{resource_requirements}}

**Budget Estimation:** {{budget_estimation}}

## 9. Pilot Study
**Pilot Study Design:** {{pilot_design}}

**Pilot Sample Size:** {{pilot_sample}}

**Success Criteria:** {{pilot_success_criteria}}

## 10. Reporting Plan
**Documentation Plan:** {{documentation_plan}}

**Dissemination Strategy:** {{dissemination_strategy}}

**Pre-registration Details:** {{preregistration_details}}

---

**Experiment Designed By:** {{researcher_name}}
**Date:** {{design_date}}
**Version:** {{version}}''',
    "fields": [
      {
        "id": "research_question",
        "label": "Primary Research Question",
        "type": "textarea",
        "placeholder": "What is the specific question your research aims to answer?",
        "isRequired": true
      },
      {
        "id": "null_hypothesis",
        "label": "Null Hypothesis (H0)",
        "type": "textarea",
        "placeholder": "State the null hypothesis that assumes no effect or relationship",
        "isRequired": true
      },
      {
        "id": "alternative_hypothesis",
        "label": "Alternative Hypothesis (H1)",
        "type": "textarea",
        "placeholder": "State the alternative hypothesis that suggests an effect or relationship exists",
        "isRequired": true
      },
      {
        "id": "independent_variables",
        "label": "Independent Variables",
        "type": "textarea",
        "placeholder": "List and describe the variables you will manipulate",
        "isRequired": true
      },
      {
        "id": "dependent_variables",
        "label": "Dependent Variables",
        "type": "textarea",
        "placeholder": "List and describe the outcome measures you will record",
        "isRequired": true
      },
      {
        "id": "control_variables",
        "label": "Control Variables",
        "type": "textarea",
        "placeholder": "List variables that will be held constant across conditions",
        "isRequired": true
      },
      {
        "id": "design_type",
        "label": "Experimental Design Type",
        "type": "dropdown",
        "options": [
          "Between-subjects",
          "Within-subjects",
          "Mixed design",
          "Factorial design",
          "Randomized controlled trial",
          "Quasi-experimental design",
          "Time series design",
          "Cross-sectional design",
          "Longitudinal design",
          "Case-control design",
          "Other (specify in justification)"
        ],
        "isRequired": true
      },
      {
        "id": "design_justification",
        "label": "Justification for Design Choice",
        "type": "textarea",
        "placeholder": "Explain why this experimental design is appropriate for your research question",
        "isRequired": true
      }
    ],
    "metadata": {
      "templateVersion": "1.2",
      "author": "Research Methods Team",
      "lastUpdated": "2023-09-15",
      "recommendedUses": [
        "Academic research", 
        "Scientific studies",
        "Laboratory experiments",
        "Field experiments"
      ],
      "complexity": "Advanced"
    }
  };

  /// Literature Review Template
  static final Map<String, dynamic> literatureReviewTemplate = {
    "id": "systematic_literature_review",
    "title": "Systematic Literature Review Protocol",
    "description": "Structured framework for conducting thorough systematic literature reviews",
    "category": "Research Methods",
    "domain": "research",
    "templateContent": '''# Systematic Literature Review Protocol

## 1. Review Information
**Review Title:** {{review_title}}
**Lead Researcher:** {{lead_researcher}}
**Team Members:** {{team_members}}
**Protocol Version:** {{protocol_version}}
**Date:** {{protocol_date}}

## 2. Background and Rationale
**Research Domain:** {{research_domain}}

**Background:**
{{background}}

**Review Rationale:**
{{rationale}}

**Existing Reviews:**
{{existing_reviews}}

## 3. Review Objectives and Questions
**Primary Objective:**
{{primary_objective}}

**Research Questions:**
{{research_questions}}

**PICO/SPIDER Framework:**
- Population/Sample: {{population}}
- Intervention/Phenomenon of Interest: {{intervention}}
- Comparison/Context: {{comparison}}
- Outcomes/Design: {{outcomes}}
- (Evaluation/Research type): {{evaluation}}

## 4. Methodology
### 4.1 Eligibility Criteria
**Inclusion Criteria:**
{{inclusion_criteria}}

**Exclusion Criteria:**
{{exclusion_criteria}}

**Types of Studies:**
{{study_types}}

**Publication Timeframe:**
{{timeframe}}

**Language Restrictions:**
{{language_restrictions}}

### 4.2 Information Sources
**Databases to be Searched:**
{{databases}}

**Gray Literature Sources:**
{{gray_literature}}

**Hand Searching:**
{{hand_searching}}

**Expert Consultation:**
{{expert_consultation}}

### 4.3 Search Strategy
**Key Concepts:**
{{key_concepts}}

**Search String Development:**
{{search_development}}

**Final Search Strings:**
{{search_strings}}

### 4.4 Study Records
**Data Management:**
{{data_management}}

**Selection Process:**
{{selection_process}}

**Data Collection Process:**
{{data_collection_process}}

**Data Items to Extract:**
{{data_items}}

## 5. Quality Assessment
**Risk of Bias Assessment Tool:**
{{bias_assessment_tool}}

**Quality Assessment Criteria:**
{{quality_criteria}}

**Quality Assessment Process:**
{{quality_process}}

## 6. Data Synthesis
**Synthesis Method:**
{{synthesis_method}}

**Quantitative Analysis Plan (if applicable):**
{{quantitative_analysis}}

**Qualitative Synthesis Approach (if applicable):**
{{qualitative_synthesis}}

**Subgroup Analyses:**
{{subgroup_analyses}}

**Assessment of Reporting Biases:**
{{reporting_biases}}

## 7. Confidence in Findings
**Strength of Evidence Assessment:**
{{evidence_strength}}

**Applicability Assessment:**
{{applicability}}

## 8. Project Management
**Timeline:**
{{timeline}}

**Resource Requirements:**
{{resources}}

**Software to be Used:**
{{software}}

## 9. Dissemination Plans
**Publication Strategy:**
{{publication_strategy}}

**Target Journals/Conferences:**
{{target_venues}}

**Registration Details:**
{{registration_details}}

---

**Protocol Prepared By:** {{protocol_author}}
**Date:** {{preparation_date}}''',
    "fields": [
      {
        "id": "review_title",
        "label": "Review Title",
        "type": "text",
        "placeholder": "Concise title of your literature review",
        "isRequired": true
      },
      {
        "id": "lead_researcher",
        "label": "Lead Researcher",
        "type": "text",
        "placeholder": "Name and affiliation of the lead researcher",
        "isRequired": true
      },
      {
        "id": "team_members",
        "label": "Team Members",
        "type": "textarea",
        "placeholder": "Names and affiliations of all team members involved in the review",
        "isRequired": false
      },
      {
        "id": "protocol_version",
        "label": "Protocol Version",
        "type": "text",
        "placeholder": "e.g., 1.0",
        "isRequired": true
      },
      {
        "id": "protocol_date",
        "label": "Protocol Date",
        "type": "date",
        "isRequired": true
      },
      {
        "id": "research_domain",
        "label": "Research Domain",
        "type": "text",
        "placeholder": "The field or domain of research",
        "isRequired": true
      }
    ]
  };

  // Additional research templates would be defined here
  static final Map<String, dynamic> researchProtocolTemplate = {
    "id": "research_protocol_template",
    "title": "Comprehensive Research Protocol",
    "description": "Detailed protocol template for planning research studies across disciplines",
    "category": "Research Planning",
    "domain": "research",
    // Add template content and fields here
  };
  
  static final Map<String, dynamic> dataAnalysisTemplate = {
    "id": "data_analysis_plan",
    "title": "Data Analysis Plan",
    "description": "Structured template for planning quantitative and qualitative data analysis",
    "category": "Data Analysis",
    "domain": "research",
    // Add template content and fields here
  };
  
  static final Map<String, dynamic> userResearchTemplate = {
    "id": "user_research_protocol",
    "title": "User Research Protocol",
    "description": "Framework for planning and conducting user research studies",
    "category": "User Research",
    "domain": "research",
    // Add template content and fields here
  };
  
  static final Map<String, dynamic> hypothesisTestingTemplate = {
    "id": "hypothesis_testing_framework",
    "title": "Hypothesis Testing Framework",
    "description": "Template for formulating and testing research hypotheses",
    "category": "Research Methods",
    "domain": "research",
    // Add template content and fields here
  };
  
  static final Map<String, dynamic> researchEthicsTemplate = {
    "id": "research_ethics_checklist",
    "title": "Research Ethics Checklist",
    "description": "Comprehensive checklist for ensuring ethical research practices",
    "category": "Research Ethics",
    "domain": "research",
    // Add template content and fields here
  };
}
