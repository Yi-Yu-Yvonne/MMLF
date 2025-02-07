tasks=("dbpedia-entity" "fiqa" "trec-covid" "webis-touche2020" "nfcorpus") # "fever" "hotpotqa" "msmarco" "nq"
base_models=("e5-small-v2" "contriever")
llm_models=("meta-llama/llama-3-70b-instruct") # "meta-llama/Meta-Llama-3-8B-Instruct"

for llm in "${llm_models[@]}"; do
    for task_type in "${tasks[@]}"; do
        for base_model in "${base_models[@]}"; do
        # 3.4 Main Results
            # Raw Query
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type rawQ   --task "$task_type" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RawQuery-${task_type}.json" > Log/${base_model}/${llm}/RawQuery-${task_type}.log 2>&1
            
            # Query2Doc
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type Q2D --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/Q2D/Q2D-${task_type}.json" > Log/${base_model}/${llm}/Query2Doc-${task_type}.log 2>&1  && \
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type single --concat_original  --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/Q2D/Q2D-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/Query2Doc-${task_type}.json" >> Log/${base_model}/${llm}/Query2Doc-${task_type}.log 2>&1

            # CoT 
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type CoT --task "$task_type"  --queries_file "/path/to/Generated_Results/${llm}/CoT/CoT-${task_type}.json" > Log/${base_model}/${llm}/CoT-${task_type}.log 2>&1  && \
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type single --concat_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/CoT/CoT-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/CoT-${task_type}.json" >> Log/${base_model}/${llm}/CoT-${task_type}.log 2>&1

            # MQR w/ RRF
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MQRwRRF-${task_type}.log 2>&1 && \
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MQRwRRF-${task_type}.json" >> Log/${base_model}/${llm}/MQRwRRF-${task_type}.log 2>&1
    
            # MILL (w/o PRF & MV) 
            nohup python Generate.py --llm_model "$llm" --generation_stage combined --generation_type QQD --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/QQD(mQ)/QQD(mQ)-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/QQD(mP)/QQD(mP)-${task_type}.json"  > Log/${base_model}/${llm}/MILL-${task_type}.log 2>&1  && \
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type single --concat_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/QQD(mP)/QQD(mP)-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MILL-${task_type}.json" >> Log/${base_model}/${llm}/MILL-${task_type}.log 2>&1
    
            # MMLF
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type"  --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MMLF-${task_type}.log 2>&1 && \
            nohup python Generate.py --llm_model "$llm" --generation_stage second --generation_type CQE --task "$task_type" --queries_file "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" >> Log/${base_model}/${llm}/MMLF-${task_type}.log 2>&1  && \
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MMLF-${task_type}.json" >> Log/${base_model}/${llm}/MMLF-${task_type}.log 2>&1   
  

        # 3.5.1 Fusion Method Comparison 
            # Concatenation
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type single  --concat_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/Concat-${task_type}.json" > Log/${base_model}/${llm}/Concat-${task_type}.log 2>&1
            
            # CombSUM
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method CombSUM --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/CombSUM-${task_type}.json" > Log/${base_model}/${llm}/CombSUM-${task_type}.log 2>&1
            
            # Reciprocal Rank Fusion (RRF) == MMLF
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RRF-${task_type}.json" > Log/${base_model}/${llm}/RRF-${task_type}.log 2>&1


        # 3.5.2 Role of the Original Query
            # RRF w/o q
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --task "$task_type" --queries_file  "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RRFwoq-${task_type}.json" > Log/${base_model}/${llm}/RRFwoq-${task_type}.log 2>&1
            
            # RRF w/ q concatenated
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --concat_original --task "$task_type" --queries_file  "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RRFwq_concat-${task_type}.json" > Log/${base_model}/${llm}/RRFwq_concat-${task_type}.log 2>&1
            
            # RRF w/ q include == MMLF
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file  "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RRFwq_include-${task_type}.json" > Log/${base_model}/${llm}/RRFwq_include-${task_type}.log 2>&1
            
            # RRF w/ q included and concatenated
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --concat_original  --task "$task_type" --queries_file  "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/RRFwq_include_concat-${task_type}.json"  > Log/${base_model}/${llm}/RRFwq_include_concat-${task_type}.log 2>&1


        # 3.5.3 Query Reformulation Pipeline
            # MQ = MQR
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MQ-${task_type}.log 2>&1 
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file  "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --result_file  "/path/to/Evaluation_Results/${base_model}/${llm}/MQ-${task_type}.json" >> Log/${base_model}/${llm}/MQ-${task_type}.log 2>&1
    
            # MP = MCQE
            nohup python Generate.py --llm_model "$llm" --generation_stage combined --generation_type MCQE --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MCQE(mQ)/MCQE(mQ)-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MCQE(mP)/MCQE(mP)-${task_type}.json" > Log/${base_model}/${llm}/MP-${task_type}.log 2>&1 
            nohup python Retrieve.py ---base_model "$base_model" -retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MCQE(mP)/MCQE(mP)-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MP-${task_type}.json"  >> Log/${base_model}/${llm}/MP-${task_type}.log 2>&1
    
            # MQ2MP = MQR + CQE == MMLF
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MP2MQ-${task_type}.log 2>&1 
            nohup python Generate.py --llm_model "$llm" --generation_stage second --generation_type CQE --task "$task_type" --queries_file "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" >> Log/${base_model}/${llm}/MP2MQ-${task_type}.log 2>&1 
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MP2MQ-${task_type}.json" >> Log/${base_model}/${llm}/MP2MQ-${task_type}.log 2>&1

        # Appendix C Impact of Prompts
            # MQR + CQE == MMLF
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MQR_CQE-${task_type}.log 2>&1 
            nohup python Generate.py --llm_model "$llm" --generation_stage second --generation_type CQE --task "$task_type" --queries_file "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" >> Log/${base_model}/${llm}/MQR_CQE-${task_type}.log 2>&1 
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MMLF/MMLF-${task_type}.json" --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MQR_CQE-${task_type}.json" >> Log/${base_model}/${llm}/MQR_CQE-${task_type}.log 2>&1

            # MQR + Q2D
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MQR_Q2D-${task_type}.log 2>&1 
            nohup python Generate.py --llm_model "$llm" --generation_stage second --generation_type CQE --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MQR_Q2D/MQR_Q2D-${task_type}.json"  >> Log/${base_model}/${llm}/MQR_Q2D-${task_type}.log 2>&1 
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR_Q2D/MQR_Q2D-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MQR_Q2D-${task_type}.json" >> Log/${base_model}/${llm}/MQR_Q2D-${task_type}.log 2>&1
            
            # MQR + CoT
            nohup python Generate.py --llm_model "$llm" --generation_stage first --generation_type MQR --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" > Log/${base_model}/${llm}/MQR_CoT-${task_type}.log 2>&1 
            nohup python Generate.py --llm_model "$llm" --generation_stage second --generation_type COT --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR/MQR-${task_type}.json" --passages_file "/path/to/Generated_Results/${llm}/MQR_CoT/MQR_CoT-${task_type}.json" >> Log/${base_model}/${llm}/MQR_CoT-${task_type}.log 2>&1 
            nohup python Retrieve.py --base_model "$base_model" --retrieval_type multiple  --fusion_method RRF --include_original --task "$task_type" --queries_file "/path/to/Generated_Results/${llm}/MQR_CoT/MQR_CoT-${task_type}.json"  --result_file "/path/to/Evaluation_Results/${base_model}/${llm}/MQR_CoT-${task_type}.json" >> Log/${base_model}/${llm}/MQR_CoT-${task_type}.log 2>&1
            
        done
    done
done
