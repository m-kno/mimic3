def modelling(clf, grid, cv, score, data):
    """
        clf: Instance of the modell
        grid: parameter grid
        cv: crossvalidation
        score: scoring parameter
        data: data to use as list(train/test-split)
        
        Returns a dictionary with the scorings and best parameter
    """
    start = time()
    X_train, X_test, y_train, y_test = data
    
    grid_model = GridSearchCV(clf, param_grid=grid, 
                        cv=cv, 
                        verbose=False, n_jobs=-1,
                        scoring=score)
    best_model = grid_model.fit(X_train, y_train)
    #model.fit(X_train, y_train)
    y_pred = best_model.predict(X_test)
    
    scores = {'test':{},
             'train': {}}
    scores['Best_Parameter'] = best_model.best_params_
    scores['test'] = {'F1_score': f1_score(y_test, y_pred),
                      'Accuracy': accuracy_score(y_test, y_pred),
                      'Precision': precision_score(y_test, y_pred),
                      'Recall': recall_score(y_test, y_pred),
                      'AUC': roc_auc_score(y_test, y_pred),
                      'Seconds': round(time()-start,1)}
    return scores

def get_test_results(model_list):
    """
        Needs a list of models with a list of parameters for each modeL:
        - Name of Model
        - Instance of the Model,
        - Grid
        - crossvalidation,
        - scoring parameter
        - data
    """
    start = time()
    results = {m[0]:modelling(*m[1:]) for m in model_list}
    test_result = {k:v['test'] for k, v in results.items()}
    for k, v in results.items():
        test_result[k]['Best_Parameter'] = v['Best_Parameter']
    df_test = pd.DataFrame(test_result).T
    df = df_test[['F1_score', 'Accuracy', 'Precision', 'Recall', 'AUC','Seconds', 'Best_Parameter']]
    print(f'Runtime: ist {(time()-start):.1f} seconds')
    return df
